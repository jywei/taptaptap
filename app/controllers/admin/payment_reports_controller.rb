class Admin::PaymentReportsController < Admin::ApplicationController
  before_action :set_params, only: :index

  def index
    if @source.present?
      if @direction == 'search'
        @stat = StatisticByTransferedData
          .search
          .where(source: @source, for_date: @start_date..@end_date)
          .page((params[:page] || 1) )
          .per(20)
          .order('id DESC')
      else
        @stat = StatisticByTransferedData.get_data({ source: @source, for_date: @start_date..@end_date, direction: @direction})
      end

      # TODO: rewrite to SELECT R.rate * S.amount AS cost FROM statistics_by_transfered_data AS S RIGHT JOIN payment_rates AS R ON auth_token, source, direction
      @rate = PaymentRate.find_by(source: @source, direction: @direction)
    end

    @sources = {"" => 'select source'}.merge PostingConstants::SOURCES_NAMES
    @cat_group_names = PostingConstants::CATEGORY_GROUPS_NAMES

    add_breadcrumb "Payment Reports"
  end

  private

  def set_params
    @source = reports_params[:source] || session[:source] || 'CRAIG'
    session[:source] = @source

    @direction = reports_params[:direction] || session[:direction] || :in
    session[:direction] = @direction

    time = Time.now

    @start_date = reports_params[:start_date] || time.at_beginning_of_month.strftime("%Y/%m/%d")
    @end_date = reports_params[:end_date] || time.at_end_of_month.strftime("%Y/%m/%d")
  end

  def reports_params
    params.permit(:source, :direction, :start_date, :end_date)
  end
end