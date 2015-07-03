class Posting < ActiveRecord::Base
  #include ::PostingValidation
  include ::PostingConstants
  include ::PostingGeoStatuses

  #validates :source, :category, :external_id, :heading, :timestamp, presence: true
  validates :source, :inclusion => {:in => Posting::SOURCES}
  validates :category, :inclusion => {:in => Posting::CATEGORIES, :message => "is not included in list: %{value}"}
  validates :status, :inclusion => {:in => Posting::STATUSES, :message => "is not included in list: %{value}"}
  #validates :language, :format => {:with => /\A\w{2}\z/i}, :allow_blank => true
  #validates :currency, :format => {:with => /\A\w{3}\z/i}, :allow_blank => true

  attr_accessor :location, :already_geolocated

  serialize :images
  before_save :encode_annotations
  after_save :decode_annotations
  after_find :decode_annotations

  scope :remls, -> { where("source = 'REMLS'") }
  scope :hmngs, -> { where("source = 'HMNGS'") }
  scope :ebaym, -> { where("source = 'EBAYM'") }
  scope :craig, -> { where("source = 'CRAIG'") }
  scope :jboom, -> { where("source = 'JBOOM'") }
  scope :carsd, -> { where("source = 'CARSD'") }
  scope :bkpge, -> { where("source = 'BKPGE'") }
  scope :autod, -> { where("source = 'AUTOD'") }

  scope :within_time, ->(from, to) {
    where("created_at >= ? and created_at < ?", from, to)
  }

  scope :within_id, ->(from, to) {
    where("id >= ? and id < ?", from, to)
  }

  def location
    {"country" => self.country, "state" => self.state, "county" => self.county,
      "locality" => self.locality, "city" => self.city, "region" => self.region,
      "city" => self.city, "metro" => self.metro}
  end

  class << self
    def recent_by_source
    end

    def mysql_connection
      @mysql_connection ||= Mysql2::Client.new(
          {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
      )
    end

    def close_mysql_connection
      return if @mysql_connection.blank?
      @mysql_connection.close
      @mysql_connection = nil
    end

    def location_as_hash(posting)
      json_location = {}
      Location::LEVELS.each { |level| json_location[level] = posting[level] }
      json_location['formatted_address'] = posting['formatted_address']
      json_location['lat'] = posting['lat']
      json_location['long'] = posting['long']
      json_location['accuracy'] = posting['accuracy']
      json_location['geolocation_status'] = posting['geolocation_status']
      json_location.delete_if { |field, value| value.blank? }
      json_location
    end
  end

  def self.check_columns_widths(data)
    data.each do |key, value|
      next if value.blank? or not Posting::COLUMNS_WIDTHS.keys.include? key

      allowed = Posting::COLUMNS_WIDTHS[key.to_s]

      if value.size > allowed
        redis_value = RedisHelper.get_redis.hget("column_overflow", key)

        if (redis_value.present? and redis_value.to_i < value.size) or (redis_value.blank?)
          RedisHelper.get_redis.hset "column_overflow", key, value.size
        end
      end
    end
  end

  def anchor
    id
  end

  def encode_annotations
    self.annotations = Oj.dump(self.annotations) if self.respond_to? :annotations
  end

  def decode_annotations
    self.annotations = Oj.load(self.annotations) if self.respond_to? :annotations
  end
end
