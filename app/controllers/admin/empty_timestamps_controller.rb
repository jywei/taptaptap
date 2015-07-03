class Admin::EmptyTimestampsController < Admin::ChartController
  add_breadcrumb :empty_timestamps, :admin_empty_timestamps_path

  before_action :dates, only: [ :index ]

  def index
    @series = [
      {
        name: "count",
        data: StatisticByEmptyTimestamp.get_data(@start_date, @end_date)
      }
    ]

    @chart_options = default_chart_options
  end

  def show_ids
    @date = (Date.parse(date_params[:date]) || Date.today).strftime("%Y-%m-%d")
    @ids = Kaminari.paginate_array(StatisticByEmptyTimestamp.get_empty_ids(@date)).page(date_params[:page]).per(25)
  end
end
