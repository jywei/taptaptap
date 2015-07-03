class Admin::LatencyStatisticsController < Admin::ChartController
  add_breadcrumb :latencies, :admin_statistics_path

  before_action :default_dates, only: :index

  def index
    @latency_offset = RedisHelper.get_redis.get("latency_offset") || 100

    periods = [:hourly, :daily, :monthly]

    @series = {}    

    periods.each{|period| @series[period] = LatencyHourlyStatistic.send(period)}

    @chart_options = default_chart_options.merge(latency_chart_options)
  end
  
  def update_latency_offset
    RedisHelper.get_redis.set("latency_offset", latency_params[:latency_offset].to_i)
    render json: {status: "ok"}.to_json
  end

  def latency_hourly
    render json: LatencyHourlyStatistic.hourly(DateTime.parse(latency_params[:date] + ":00:00 GMT-04:00", "%Y-%m-%d %H:%M %Z")).to_json 
  end

  def latency_daily
    render json: LatencyHourlyStatistic.daily(DateTime.parse(latency_params[:date])).to_json
  end

  def latency_monthly
    render json: LatencyHourlyStatistic.monthly(DateTime.parse(latency_params[:date] + "-01")).to_json
  end

  def latency_day_hourly
    render json: LatencyHourlyStatistic.day_hourly(DateTime.parse(latency_params[:date])).to_json
  end  

  private

  def default_dates
    @default_hour = (Time.now - 1.hour).strftime("%H")
    @default_hour_day = Time.now.strftime("%Y-%m-%d")

    @min_day = StatisticByLatency.min_day
    @max_day = StatisticByLatency.max_day
    @default_day = (Time.now - 1.day).strftime("%Y-%m-%d")
    
    
    @min_month = StatisticByLatency.min_month
    @max_month = StatisticByLatency.max_month
    @default_month = Time.now.strftime("%Y-%m")
  end  

  def latency_params
    params.permit(:latency_offset, :date)
  end 

  def latency_chart_options
    {
      plotOptions: {
        column: {
          allowPointSelect: true,
          colorByPoint: true,
          colors: ['#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#8085e8', '#8d4653', '#91e8e1']
        }
      }
    }
  end 

end 