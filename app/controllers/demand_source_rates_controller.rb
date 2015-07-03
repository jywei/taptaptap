class DemandSourceRatesController < ApplicationController
  layout 'payments'

  before_action :check_client
  before_action :set_params, only: [:index, :edit]
  before_action :verify_authenticity_token, only: :update_rates

  def index
    @source_rates = {}

    @available_groups = session[:available_groups] || StatisticByTransferedData.get_available_groups
    session[:available_groups] = @available_groups

    @available_groups.keys.each do |source|
      @source_rates[source] =  DemandSourceRate.find_by(auth_token: @client.auth_token,  direction: @direction, source: source)

      unless @source_rates[source]
        @source_rates[source] =  DemandSourceRate.create(auth_token: @client.auth_token,  direction: @direction, source: source, all_groups: (source == "CRAIG"))
      end
    end

    # add_breadcrumb "Demand Rates"
  end

  def edit
    @source_rate = DemandSourceRate.find(params[:id])

    if @source_rate.source == "CRAIG" &&  @source_rate.demand_group_rates.empty?
      @available_groups = session[:available_groups] || StatisticByTransferedData.get_available_groups
      @available_groups[@source_rate.source].each do |group|
        @source_rate.demand_group_rates.create(group: group)
      end
    end


    # add_breadcrumb "Demand rates", demand_source_rates_path
    # add_breadcrumb "Edit rate"
  end

  def update
    row = DemandSourceRate.find(params[:id])
    row.update_attributes(demand_params)

    redirect_to demand_source_rates_path
  end

  private

  def check_client
    if session[:client].blank?
      redirect_to login_path and return
    end

    @client = session[:client]
  end

  def set_params
    @direction = params[:direction] || session[:direction] || :out
    session[:direction] = @direction

    @source = params[:source] || "CRAIG"

    @sources = PostingConstants::SOURCES_NAMES
    @groups = PostingConstants::CATEGORY_GROUPS_NAMES
  end

  def demand_params
    params.require(:demand_source_rate).permit(:max_sum, :rate, :all_groups).tap do |whitelisted|
      if params[:demand_source_rate][:demand_group_rates_attributes].present?
        whitelisted[:demand_group_rates_attributes] = params[:demand_source_rate][:demand_group_rates_attributes]
      end
    end
  end
end