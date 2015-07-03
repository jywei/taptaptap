class Admin::InsertProfilersController < Admin::ApplicationController

  def index
    @source = insert_params[:source] || 'all'
    if  @source == 'all'
      @inserts = InsertProfiler.order('created_at desc').page(params[:page] || 1).per(20)
    else
      @inserts = InsertProfiler.where(source: @source).order('created_at desc').page(params[:page] || 1).per(20)
    end
    @sources = [['All sources', 'all']] + PostingConstants::SOURCES

    add_breadcrumb 'Insert Profiling'
  end

  private
  def insert_params
    params.permit(:source)
  end


end