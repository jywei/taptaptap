require 'active_support/core_ext/hash'

class Statistics::CollectDataService
  attr_accessor :postings, :start_time, :end_time, :stats

  def initialize timestamp
    id1,id2 = PostingThreshold.
        select('posting_id').
        where("posting_created_at >= ?", timestamp).
        order('id asc').
        limit(2).
        collect(&:posting_id)

    @start_time = timestamp
    @end_time = timestamp + 1.minute
    volume = id1/1_000_000
    Posting.table_name = "postings#{volume}"
    @postings = Posting.within_id(id1, id2).to_a

    if id2/1_000_000 != id1/1_000_000
      Posting.table_name = "postings#{volume + 1}"
      postings = Posting.within_id(id1, id2)
      @postings += postings.to_a
    end
    stats_from_redis = RedisHelper.get_redis.get(@start_time.to_i)
    @stats = stats_from_redis ? JSON.parse(stats_from_redis) : {}
  end

  def perform
    Statistic.create(timestamp: end_time.beginning_of_minute, data: {
      postings_processed: {
        num_postings: number_of_postings_processed,
        # total_time: total_time,
        avg_time: processing_time[:avg],
        max_time: processing_time[:max],
        avg_validation_time: validation_time[:avg],
        max_validation_time: validation_time[:max],
        avg_response_time: response_time[:avg],
        max_response_time: response_time[:max],
        num_workers: number_of_background_workers,
        num_queues: 0,
        num_queued_jobs: 0,
        num_processed_jobs: 0,
        num_failed_jobs: 0,
        avg_job_time: job_processing_time[:avg],
        max_job_time: job_processing_time[:max]
        #new stats
        #gap_between_anchor_and_last_posting: 0, #count
        #add_posting_poll_posting_latency: 0, #ms ; also other latencies can be added: add-geolocate, geolocate-anchor, anchor-poll latencies

      }.merge(calculate_per_entity),
      postings_geolocator_request: geolocator_stats
    })
  end

  private

  def f
    processing_time
    data = stats[Statistics::POSTING_INSERT]
    job_process_time = data.present? ? {avg: data.avg.round, max: data.max.round} : {avg: 0, max: 0}
  end

  def number_of_postings_processed
    postings.count
  end

  def calculate_per_entity
    by_sources = {}
    PostingConstants::SOURCES.each do |source|
      #count = postings.where(source: source).count
      count = postings.select{|p| p.source == source}.size
      by_sources[source] = count if count > 0
    end

    by_categories = {}
    PostingConstants::CATEGORIES.each do |cat|
      #count = postings.where(category: cat).count
      count = postings.select{|p| p.category == cat}.size
      by_categories[cat] = count if count > 0
    end

    metros = postings.collect(&:metro).uniq
    by_locations = {}
    metros.each do |metro|
      #count = postings.where(metro: metro).count
      count = postings.select{|p| p.metro == metro}.size
      by_locations[metro] = count if count > 0
    end

    by_statuses = {}
    PostingConstants::STATUSES.each do |status|
      #count = postings.where(status: status).count
      count = postings.select{|p| p.status == status}.size
      by_statuses[status] = count if count > 0
    end

    remote_ips = postings.map(&:transit_ip_address).uniq
    by_remote_ips = {}
    remote_ips.each do |remote_ip|
      #count = postings.where(transit_ip_address: remote_ip).count
      count = postings.select{|p| p.transit_ip_address == remote_ip}.size
      by_remote_ips[remote_ip] = count if count > 0
    end

    # auth_tokens = postings.select('auth_token').uniq.map(&:auth_token)
    # by_auth_tokens = {}
    # auth_tokens.each do |auth_token|
    #  count = postings.where(auth_token: auth_token).count
    #  by_auth_tokens[auth_token] = count if count > 0
    # end

    {
      num_by_source: by_sources.to_json,
      num_by_category: by_categories.to_json,
      num_by_location: by_locations.to_json,
      num_by_status: by_statuses.to_json,
      num_by_remote_ip: by_remote_ips.to_json
      # num_by_auth_token: by_auth_tokens.to_json
    }
  end

  def validation_time
    data = stats[Statistics::POSTING_VALIDATION]
    data.present? ? {avg: data.avg.round, max: data.max.round} : {avg: 0, max: 0}
  end

  def response_time
    data = stats[Statistics::POSTING_RESPONDING]
    data.present? ? {avg: data.avg.round, max: data.max.round} : {avg: 0, max: 0}
  end

  def number_of_background_workers
    SystemState.select("geo_runners").where("created_at > ? AND created_at < ?",start_time, end_time).sum("geo_runners")
  end

  def job_processing_time
    data = stats[Statistics::BACKGROUND_TIME]
    job_process_time = data.present? ? {avg: data.avg.round, max: data.max.round} : {avg:0, max:0}
  end

  def geolocator_stats
    geo = stats[Statistics::GEO_STATS]
    geo.first if geo
  end

  private

  def resque_info
    @resque_info ||= Resque.info
  end

end
