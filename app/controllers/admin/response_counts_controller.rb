class Admin::ResponseCountsController < ApplicationController

  def index
    @rc = ResponseCount.page(params[:page]).per(20)
  end

  def filter_by_address
    @address = params[:request_ip]
    @rcfilter = ResponseCount.count_per_day(@address)
  end

  def filter_by_date
    @date = params[:date]
    @rcfilter = ResponseCount.count_for_address(@date)
  end

end
