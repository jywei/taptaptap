class Admin::SourcesController < Admin::ApplicationController
  DEFAULT_LIMIT = 24

  before_action :init_limit, only: :index

  def index
    @track_carmakers = PostingConstants::TRACK_CARMAKER_SOURCES

    @sources = Posting2.recent_postings_by_source
    
    add_breadcrumb :sources, :admin_sources_path
  end

  def zips_by_source
    @time = Time.now
    
    @source = source_params[:source]
    zips = ZipsTracker.get_zips(@source)
    
    @present_zips = zips[:present]
    @missing_zips = zips[:missing]
    
    add_breadcrumb "Sources", :admin_sources_path
    add_breadcrumb "Last date by zips"
  end  

  def carmakers_by_source
    @source = source_params[:source]
    
    if PostingConstants::TRACK_CARMAKER_SOURCES.include?(@source)    
      @time = Time.now
      
      carmakers = Carmaker.get_data(@source)
      
      @present_carmakers = carmakers[:present]
      @missing_carmakers = carmakers[:missing]
      
      add_breadcrumb "Sources", :admin_sources_path
      add_breadcrumb "Carmakers"
    else
      redirect_to action: :index
    end
  end  

  private

  def init_limit
    @limit = (params[:hours] || DEFAULT_LIMIT).to_i.hours.ago
  end

  def source_params
    params.permit(:source)
  end  
end
