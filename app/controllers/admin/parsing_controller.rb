class Admin::ParsingController < Admin::ApplicationController
  add_breadcrumb :parsing_manager, :admin_parsing_path
  before_filter :check_source, only: :create

  def index
    @source = params[:source] || Posting::SOURCES_FOR_PARSING.first
    @postings = PostingExample.where(source: @source).order('id DESC').to_a
  end

  def show
    send_file "lib/data/#{params[:source]}_parsing_configuration.csv"
  end

  def create
    path = File.join('lib/data', "#{params[:source]}_parsing_configuration.csv")
    File.open(path, "wb") { |f| f.write(params['parsing_configuration'].read) } if params['parsing_configuration'].present?
    redirect_to admin_parsing_path
  end

  private

  def check_source
    redirect_to admin_parsing_path if params[:source] == 'mockup'
  end
end
