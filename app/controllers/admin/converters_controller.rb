class Admin::ConvertersController < ApplicationController
  before_action :add_variables, only: [:new, :edit]
  add_breadcrumb "Home", :admin_path
  def index
    @converters = Converter.all
    add_breadcrumb "index", admin_converters_path
  end

  def new
    @converter = Converter.new
    existent_converter_sources = Converter.pluck(:source)
    @sources = @sources - existent_converter_sources
    add_breadcrumb "Converters", :admin_converters_path
    add_breadcrumb "New"
  end

  def edit
    @converter = Converter.find params[:id]
    add_breadcrumb "Converters", :admin_converters_path
    add_breadcrumb "Edit"
  end

  def create
    @converter = Converter.new(converter_params)
    if @converter.save
      redirect_to admin_converters_path
    else
      render :new
    end
  end

  def update
    @converter = Converter.find params[:id]
    if @converter.update_attributes converter_params
      redirect_to admin_converters_path
    else
      render :edit
    end
  end

  private
    def converter_params
      if params[:converter][:convert_status_values].present?
        params[:converter][:convert_status_values].delete("")
      else
        params[:converter][:convert_status_values] = []
      end
      if params[:converter][:convert_state_values].present?
        params[:converter][:convert_state_values].delete("")
      else
        params[:converter][:convert_state_values] = []
      end
      if params[:converter][:convert_flagged_status_values].present?
        params[:converter][:convert_flagged_status_values].delete("")
      else
        params[:converter][:convert_flagged_status_values] = []
      end
      params.require(:converter).permit!
    end

    def add_variables
      @flagged_statuses = Posting::FLAGGED_STATUSES.map{|el| [ el[:value],{title: "#{el[:description]}"} ]}
      @statuses = Posting::STATUSES
      @states = Posting::STATES
      @categories = Posting::CATEGORIES
      @category_groups = Posting::CATEGORY_GROUPS
      @sources = Posting::SOURCES
    end
end
