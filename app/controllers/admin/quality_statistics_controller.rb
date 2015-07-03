class Admin::QualityStatisticsController < Admin::ChartController
  add_breadcrumb :quality_statistics, :admin_quality_statistics_path

  before_action :dates, only: [ :index, :annotations_qualities, :fields_qualities ]

  def index
    @start_date = (date_params[:start_date] && Date.parse(date_params[:start_date])) || (Date.today - 1.week)
    @chart_options = default_chart_options

    @series = {
      annotations: QualityStatistic.qualities("annotations", @start_date, @end_date, partitions),
      fields: QualityStatistic.qualities("fields", @start_date, @end_date, partitions)
    }

    @qualities_config = {}

    ([ 'total' ] + PostingConstants::SOURCES).each do |source|
      @qualities_config[source] = {
          categories: [],
          postings_data: [],
          fields_quality_data: [],
          annotations_quality_data: [],
          title: "#{source.upcase} stats"
      }

      combinated_data = AverageQuality.combinated_data(@start_date, @end_date, source)

      combinated_data.each do |data|
        @qualities_config[source][:categories] << data["for_date"]
        @qualities_config[source][:postings_data] << data["postings"]
        @qualities_config[source][:fields_quality_data] << data["fields_quality"]
        @qualities_config[source][:annotations_quality_data] << data["annotations_quality"]
      end
    end

    @domain_path = "#{request.protocol}#{request.host_with_port}"
  end

  def annotations_qualities
    annotations = QualityStatistic.qualities("annotations", @start_date, @end_date, partitions)
    render json: annotations.to_json
  end

  def fields_qualities
    fields = QualityStatistic.qualities("fields", @start_date, @end_date, partitions)
    render json: fields.to_json
  end

  def incomplete_annotations
    Posting.table_name = "postings#{Posting2.current_volume}"
    @postings = Posting.where('annotations_quality < 100').select(:id, :source, :category, :annotations, :annotations_quality)
    @postings = @postings.page(params[:page] || 1).per(20)
  end

  def incomplete_fields
    Posting.table_name = "postings#{Posting2.current_volume}"
    @postings = Posting.where('fields_quality < 100').page(params[:page] || 1).per(20)
  end

  def postings_with_quality
    @quality_attribute = params[:attribute]
    @quality_lower = params[:lower]
    @quality_upper = params[:upper]

    Posting.table_name = "postings#{Posting2.current_volume}"

    query = "(#{ @quality_attribute } >= #{ @quality_lower.to_f } AND #{ @quality_attribute } <= #{ @quality_upper })"

    query += " AND source = '#{ params[:source] }'" if params[:source].present?
    query += " AND transit_ip_address = '#{ params[:transit_ip_address] }'" if params[:transit_ip_address].present?

    @postings = Posting.where(query).page(params[:page] || 1).per(20)
  end

  private

  def partitions
    if partitions_params[:start_quality] && partitions_params[:end_quality]
      { start_q: partitions_params[:start_quality].to_i, end_q: partitions_params[:end_quality].to_i }
    elsif partitions_params[:start_quality]
      # if only start_quality
      { start_q: partitions_params[:start_quality].to_i }
    elsif partitions_params[:end_quality]
      # if only end_quality
      { end_q: partitions_params[:end_quality].to_i }
    else
      {}
    end
  end

  def partitions_params
    params.permit(:start_quality, :end_quality)
  end
end

