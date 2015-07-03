class Admin::LiveLoveliesController < Admin::ApplicationController
  add_breadcrumb :live_lovelies, :admin_live_lovelies_path
  
  before_action :set_params, only: :index

  def index
    @data = LiveLovely.get_data(@start_date, @end_date)
  end
  
  private

  def set_params
    @start_date = live_params[:start_date] ?  Date.parse(live_params[:start_date]) : (Date.today - 7.days) 
    @end_date = live_params[:end_date] ?  Date.parse(live_params[:end_date]) : (Date.today) 
  end  
  
  def live_params
    params.permit(:start_date, :end_date)
  end  

end 