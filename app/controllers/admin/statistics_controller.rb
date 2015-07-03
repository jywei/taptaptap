class Admin::StatisticsController < Admin::ChartController
  add_breadcrumb :statistics, :admin_statistics_path

  layout 'admin/statistic'

  before_action :dates, only: [ :index ]

  def index
    @category_group = stat_params[:category_group]

    _old_time = Time.now.to_i

    SystemMonitor.added_counts(0, send_message = false)

    sources = {
        by_category: StatisticByCategory,
        by_category_group: StatisticByCategoryGroup,
        by_utc_hour: StatisticByUtcHour,
        ip_by_dates: StatisticByIpOnDates,
        dates_by_ip: StatisticByDatesOnIp
        # by_volume: StatisticByVolume
    }

    @series = {}

    sources.each do |key, stat|
      @series[key] = []

      ((@start_date + 1.day) .. @end_date).reverse_each do |date|
        if @category_group.present? and key == :by_category
          @series[key] << stat.get_data(date, @category_group)
        else
          @series[key] << stat.get_data(date)
        end
      end
    end

    [ :second, :minute, :hour, :day ].each do |criteria|
      @series["total_by_#{ criteria }".to_sym] = StatisticLive.get_total_data_by criteria
    end

    @series[:by_weekly_hour] = StatisticByWeeklyHour.get_data(@start_date, @end_date)
    @series[:by_long_term] = StatisticByLongTerm.get_data(Date.today)

    @chart_options = default_chart_options
  end

  def live_data
    @series_data = StatisticLive.get_data(1)

    render :json => @series_data.to_json
  end

  def total_data
    valid_criteria = %w(day hour minute second)

    @series_data = nil
    @series_data = StatisticLive.get_total_data_by(params[:criteria].to_sym) if valid_criteria.include? params[:criteria]

    render :json => @series_data.to_json
  end

  def us_borders
    render json: File.read(File.join(Rails.root, 'lib', 'data', 'us.json'))
  end

  def states_data
    updated_at = params[:updated_at]

    if updated_at.blank? or Time.parse(updated_at) < Date.today - 7.days
      states = ZipsTracker.states
    else
      states = nil
    end

    render json: { states: states, updated_at: Date.today }.to_json
  end

  def antengo
    add_breadcrumb :antengo, :antengo_admin_statistics_path

    @for_date = stat_params[:for_date] ?  Date.parse(stat_params[:for_date]) : Date.today

    @categories = PostingConstants::MCR_CATEGORIES.sort

    @data = StatisticByMetro.get_data(@for_date)

    first_record = StatisticByMetro.first

    @min_date = first_record ?  first_record.for_date : Date.today

    respond_to do |format|
      format.html { render layout: 'admin/antengo' }
    end
  end

  private

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

  def stat_params
    params.permit(:start_date, :end_date, :category_group, :source, :for_date, :from_hour, :to_hour, :state, :zoom_level, :no_rrrr)
  end
end
