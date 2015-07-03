require 'fileutils'

class TapsException < ActiveRecord::Base
  before_create :set_timestamp
  after_destroy :remove_file

  scope :daily, -> do
    time = Time.now
    where("created_at >= ? and created_at < ?", time - 1.day, time)
  end

  def log_file_exist?
    File.exists? log_file
  end

  def log_file
    File.join(Rails.root, %w(log custom traces), "#{number}.log")
  end

  def log
    log_file_exist? ? File.read(log_file) : nil
  end

  def self.track(params)
    return unless params.is_a? Hash

    message = params[:message] || 'Unknown exception'
    number = params[:number] || Time.now.to_i
    caused_by = params[:caused_by] || params[:module_name] || 'API'
    notify = params[:notify].present? ? params[:notify] : true
    details = params[:details] || ''

    message.gsub! /^#<(.+)>$/, '\1'
    message.gsub! /#?<(Object|Class|<Class>|<Object>):[a-fx0-9]+>/i, '<\1>'

    entity = find_by_message(message)

    if entity.present?
      entity.update_attributes(details: details, number: number, caused_by: caused_by, count: entity.count + 1)
    else
      create(message: message, details: details, number: number, caused_by: caused_by, notify: notify)
    end
  end

  def set_timestamp
    self.number = (Time.now.to_f*1000*1000).to_i unless self.number.present?
  end

  def self.cleanup!
    logs = Dir.glob(File.join(Rails.root, %w(log custom bodies ** *.log))).map { |f| File.basename(f).gsub(/\.log$/i, '') }
    self.where('number NOT IN (?)', logs).destroy_all
  end

  protected

  def remove_file
    Dir.glob(File.join(Rails.root, %w(log custom bodies **), "#{ self.number }.log")).each { |f| FileUtils.rm f }
  end
end
