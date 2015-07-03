class Admin::ChartController < Admin::ApplicationController
  protected

  def default_chart_options
    {
        library: {
            tooltip: {
                pointFormat: "{series.name}: <b>{point.y}</b><br/>",
                headerFormat: "<strong>{point.key}</strong><br />"
            }
        }
    }
  end

  def dates
    @min_date = (Date.today - 2.weeks).strftime("%Y-%m-%d")
    @max_date = Date.today.strftime("%Y-%m-%d")
    @start_date = (date_params[:start_date] && Date.parse(date_params[:start_date])) || (Date.today - 1.week)
    @end_date = (date_params[:end_date] && Date.parse(date_params[:end_date])) || Date.today
  end

  def date_params
    params.permit(:start_date, :end_date, :date, :page)
  end
end
