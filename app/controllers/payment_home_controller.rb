class PaymentHomeController < ApplicationController
  layout 'payments'

  before_action :check_client, except: [:index, :contracts, :categories]
  before_action :is_admin?, only: [:contract_rates]
  before_action :set_params, only: [:index, :categories]

  def index
    @data = StatisticByTransferedData.get_amount_for_groups_by_sources
    @rates = PaymentRate.get_groups_rates
  end

  def categories
    @data = StatisticByTransferedData.get_amount_for_categories_by_sources(params[:category_group])
    @rates = PaymentRate.get_categories_rates(params[:category_group])

    @categories = PostingConstants::CATEGORIES_NAMES
  end

  def contracts
    if params[:period] == 'this_month'
      @contracts = PaymentHome.this_month_incomes
    elsif params[:period] == 'last_month'
      @contracts = PaymentHome.last_month_incomes
    else
      @contracts = PaymentHome.income_by_contracts((Time.now - 1.month).at_beginning_of_month, Time.now.at_end_of_month)
    end

    respond_to do |format|
      format.html
      format.json { render json: PaymentHomeHelper.format_contracts(@contracts).to_json }
    end
  end

  def client_rates
    # @auth_token = params[:auth_token]
    @direction = params[:direction] || :in

    @client_rates = DemandSourceRate.find_by(auth_token: params[:auth_token], direction: @direction)

    @sources = PostingConstants::SOURCES_NAMES
    @groups = PostingConstants::CATEGORY_GROUPS_NAMES
  end

  private

  def set_params
    @sources = PostingConstants::SOURCES_NAMES
    @groups = PostingConstants::CATEGORY_GROUPS_NAMES
    @bounty_per_posting = 0.001
  end

  def check_client
    if session[:client].blank?
      redirect_to login_path and return
    end

    @client = session[:client]
  end

  def is_admin?
    redirect_to login_path unless  session[:client].is_admin?
  end
end
