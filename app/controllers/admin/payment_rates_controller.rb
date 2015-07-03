class Admin::PaymentRatesController < Admin::ApplicationController
  before_action :set_params, only: [:index, :edit]

  def index
    @rates = PaymentRate.send(@direction)

    add_breadcrumb "Payment Rates"
  end

  def edit
    @rate = PaymentRate.find(params[:id])

    @categories_names = PostingConstants::CATEGORIES_NAMES

    add_breadcrumb "Payment Rates", admin_payment_rates_path
    add_breadcrumb "Edit"
  end

  def update
    @rate = PaymentRate.find(params[:id])
    @rate.update_attributes(rates_params)

    redirect_to :admin_payment_rates
  end

  def update_categories_rates
    categories_rates = params[:payment_categories_rates]

    categories_rates.each do |id, rate|
      category_rate = PaymentCategoryRate.find id
      category_rate.update_attribute(:rate, rate) if category_rate.present?
    end

    render json: { success: true }.to_json
  end

  private

  def set_params
    @sources = PostingConstants::SOURCES_NAMES
    @groups = PostingConstants::CATEGORY_GROUPS_NAMES
    @available_groups = StatisticByTransferedData.get_available_groups

    @direction = params[:direction] || session[:direction] || :in
    session[:direction] = @direction
  end

  def rates_params
    params.require(:payment_rate).permit(:rate, :all_groups, :direction).tap do |whitelisted|
      if params[:payment_rate][:payment_group_rates_attributes].present?
        whitelisted[:payment_group_rates_attributes] = params[:payment_rate][:payment_group_rates_attributes]
      end
      # whitelisted[:rates_by_groups] = params[:payment_rate][:rates_by_groups]
    end
  end
end