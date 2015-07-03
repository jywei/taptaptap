#attributes:
#  threads: 1                                                         Number of threads which send postings
#  posting_time: 0.03                                                 Time spent for an insert into database of a single posting
#  posting_validation_time: 0.002                                     Time spent to error check a single posting (seconds)
#  posting_respond_time: 0.02                                         Time spent to generate response with ids and/or errors for a request with a banch of postings
#  available: 2343                                                    Number of postings that were not pulled by search api yet
#  timestamp: 2013-08-13 23:00:00.000000000 Z                         Specifies the minute during which the statistics was collected
#  per_minute:                                                        Statistics by created postings for every minute
#    :by_sources:                                                     Statistics by sources
#      HMNGS: 12
#      BKPG: 12
#    :by_categories:                                                  Statistics by categories
#      VAUT: 12
#    :by_locations:
#      ny: 12
#    :by_statuses:                                                    Statistics by statuses
#      offered: 12
#      stolen: 3
#    :by_remote_ips:                                                  Statistics by IP addresses
#      '10.0.0.1': 12
#    :by_auth_tokens:                                                 Statistics by grabbers
#      'HF45FE345GBVDCF': 12
#      'H343434334BVFVD': 12
#  background_workers:
#    :number_of_workers: 8                                            Number of background workers (Resque workers)
#    :number_of_queues: 3                                             Number of queues for background workers
#    :jobs_in_queue: 54                                               Total number of jobs in queue to be processed
#    :processed_jobs: 10943                                           Total number of processed jobs
#    :failed_jobs: 0                                                  Total number of failed jobs
#    :job_process_time: 0.2                                           Time in milliseconds to process a sinble job
#  geo_stats:
#  - total_postings: 1000                                             Number of received postings in a batch
#    already_geolocated: 50                                           Number of postings that came with geo data
#    sent_for_geolocating: 40                                         Number of postings that sent to GEO API for geolocating

class Statistic < ActiveRecord::Base
  default_scope { order('timestamp DESC') }

  serialize :data, Hash

  after_save :send_stats

  class << self
    def runner
      logger = Logger.new("/home/#{Rails.env.production? ? 'posting' : 'staging'}/posting/shared/log/stat.log")
      Statistic.init unless stat = Statistic.first

      while true do
        time = Time.now
        if s = Statistic.perform
          logger.info "#{s.timestamp}: #{(Time.now - time).round}s"
        else
          logger.info "waiting"
        end

        if File.exists?("log/kill_stat_runner.txt")
          p "Removing kill_stat_runner.txt file and ending cycle"
          %x[rm -f log/kill_stat_runner.txt]
          break
        end

      end
    rescue Exception => e
      TapsException.track(message: e.message, notify: true, details: e.backtrace.join(', '), module_name: 'stat runner')
    end

    def init
      Posting.table_name = "postings#{Posting2.current_volume}"
      posting = Posting.order('created_at ASC').first
      first_timestamp = posting.created_at.beginning_of_minute
      Statistic.create(timestamp: first_timestamp, data: {
          postings_processed: {},
          postings_geolocator_request: {}
      })
    end

    def perform
      hash, time = Statistic.count_minutely

      Statistic.create(timestamp: time, data: {
          postings_processed: hash,
          postings_geolocator_request: {}
      })
    end

    def count_minutely
      timestamp1 = Statistic.first.timestamp
      timestamp2 = timestamp1 + 1.minute
      return if timestamp2 > DateTime.now.utc

      id1, id2 = PostingThreshold.
          select('posting_id').
          where("posting_created_at >= ?", timestamp1).
          order('id asc').
          limit(2).
          collect(&:posting_id)
      return if id2.nil?

      insert_profiler = Statistic::StatisticFromInsertProfiler.new(timestamp1, timestamp2)
      raw_posting_stats = Statistic::StatisticFromRawPostings.new(timestamp1, timestamp2)
      postings_stats = Statistic::StatisticFromPostings.new(id1, id2)
      posting_stats = Statistic::StatisticFromPostingStats.new(timestamp1, timestamp2)

      hash = {
          num_received: insert_profiler.num_received,
          num_rejected: raw_posting_stats.num_rejected,
          tot_time: insert_profiler.total_time,
          avg_time: insert_profiler.avg_time,
          max_time: insert_profiler.max_time,
          avg_validation_time: 0,
          max_validation_time: 0,
          avg_response_time: insert_profiler.avg_response_time,
          max_response_time: insert_profiler.max_response_time,
          num_received_by_source: postings_stats.num_by_source,
          num_received_by_category: postings_stats.num_by_category,
          num_received_by_location: postings_stats.num_by_location,
          num_received_by_remote_ip: postings_stats.num_by_remote_ips,
          num_received_by_auth_token: insert_profiler.num_by_auth_token,
          num_rejected_by_source: raw_posting_stats.num_by_source,
          num_rejected_by_category: raw_posting_stats.num_by_category,
          num_rejected_by_location: raw_posting_stats.num_by_location,
          num_rejected_by_remote_ip: raw_posting_stats.num_by_remote_ips,
          num_rejected_by_auth_token: raw_posting_stats.num_by_auth_token,
          avg_time_by_source: insert_profiler.avg_by_source,
          max_time_by_source: insert_profiler.max_by_source,
          min_time_by_source: insert_profiler.min_by_source,
          avg_time_by_auth_token: insert_profiler.avg_by_auth_token,
          max_time_by_auth_token: insert_profiler.max_by_auth_token,
          avg_polling_api_latency: posting_stats.avg_polling_api_latency,
          max_polling_api_latency: posting_stats.max_polling_api_latency,
          avg_search_api_latency: posting_stats.avg_search_api_latency,
          max_search_api_latency: posting_stats.max_search_api_latency,
          avg_geolocator_delay: posting_stats.avg_geolocator_delay,
          max_geolocator_delay: posting_stats.max_geolocator_delay
      }

      hash = hash.map do |k, v|
        {k => (v.is_a?(Hash) ? v.to_json : v)}
      end.reduce(:merge)

      [hash, timestamp2]
    end
  end

  class StatisticFromInsertProfiler
    def initialize(timestamp1, timestamp2)
      #@timestamp1, @timestamp2 = timestamp1, timestamp2
      @data = InsertProfiler.where('created_at >= ? and created_at < ?', timestamp1, timestamp2)
    end

    def num_received
      @data.collect(&:postings_count).sum
    end

    def total_time
      collect_total_time.sum
    end

    def avg_time
      @data.collect(&:average_per_posting).avg
    end

    def max_time
      @data.collect(&:max_posting_time).compact.max || 0
    end

    def avg_response_time
      collect_total_time.avg
    end

    def max_response_time
      collect_total_time.max
    end

    def avg_by_source
      sources.inject({}) do |h, source|
        h[source.to_sym] = collect_avg_by_source(source).avg
        h
      end
    end

    def max_by_source
      sources.inject({}) do |h, source|
        h[source.to_sym] = collect_max_by_source(source).max || 0
        h
      end
    end

    def min_by_source
      sources.inject({}) do |h, source|
        h[source.to_sym] = collect_min_by_source(source).min || 0
        h
      end
    end

    def avg_by_auth_token
      auth_tokens.inject({}) do |h, token|
        h[token.to_s] = collect_avg_by_auth_token(token).avg
        h
      end
    end

    def max_by_auth_token
      auth_tokens.inject({}) do |h, token|
        a = collect_max_by_auth_token token
        h[token.to_s] = a.max || 0
        h
      end
    end

    def num_by_auth_token
      auth_tokens.inject({}) do |h, token|
        h[token.to_s] = @data.select { |ip| ip.auth_token == token }.size
        h
      end
    end

    private

    def collect_total_time
      @total_time ||= @data.collect(&:total_time)
    end

    def sources
      @sources ||= @data.collect(&:source).uniq
    end

    def collect_avg_by_source(source)
      @data.collect do |ip|
        ip.average_per_posting if ip.source == source
      end.compact
    end

    def collect_max_by_source(source)
      @data.collect do |ip|
        ip.max_posting_time if ip.source == source
      end.compact
    end

    def collect_min_by_source(source)
      @data.collect do |ip|
        ip.min_posting_time if ip.source == source
      end.compact
    end

    def collect_avg_by_auth_token(token)
      @data.collect do |ip|
        ip.average_per_posting if ip.auth_token == token
      end.compact
    end

    def collect_max_by_auth_token(token)
      @data.collect do |ip|
        ip.max_posting_time if ip.auth_token == token
      end.compact
    end

    def auth_tokens
      @auth_tokens ||= @data.collect(&:auth_token).uniq
    end
  end

  class StatisticFromPostingStats
    def initialize(timestamp1, timestamp2)
      @timestamp1, @timestamp2 = timestamp1, timestamp2
    end

    def avg_polling_api_latency
      polling_api_latency.avg.to_i
    end

    def max_polling_api_latency
      polling_api_latency.max.to_i
    end

    def avg_search_api_latency
      search_api_latency.avg.to_i
    end

    def max_search_api_latency
      search_api_latency.max.to_i
    end

    def avg_geolocator_delay
      geolocator_latency.avg.to_i
    end

    def max_geolocator_delay
      geolocator_latency.max.to_i
    end

    private

    def polling_api_latency
      PostingStat.where('anchored_at >= ? and anchored_at < ?', @timestamp1, @timestamp2).collect do |ps|
        ps.anchored_at - ps.created_at
      end.compact
    end

    def search_api_latency
      PostingStat.where('polled_at >= ? and polled_at < ?', @timestamp1, @timestamp2).collect do |ps|
        ps.polled_at - ps.created_at
      end.compact
    end

    def geolocator_latency
      PostingStat.where('located_at >= ? and located_at < ?', @timestamp1, @timestamp2).collect do |ps|
        ps.located_at - ps.created_at
      end.compact
    end
  end

  class StatisticFromPostings
    def initialize(id1, id2)
      volume = id1/1_000_000
      Posting.table_name = "postings#{volume}"
      @postings = Posting.within_id(id1, id2).to_a

      if id2/1_000_000 != id1/1_000_000
        Posting.table_name = "postings#{volume + 1}"
        postings = Posting.within_id(id1, id2)
        @postings += postings.to_a
      end

      @data = @postings
    end

    def num_by_source
      Posting::SOURCES.inject({}) do |h, source|
        h[source.to_sym] = @data.select { |p| p.source == source }.size
        h
      end
    end

    def num_by_category
      Posting::CATEGORIES.inject({}) do |h, category|
        h[category.to_sym] = @data.select { |p| p.category == category }.size
        h
      end
    end

    def num_by_location
      locations.inject({}) do |h, location|
        h[location] = @data.select { |p| p.metro == location }.size
        h
      end
    end

    def num_by_remote_ips
      remote_ips.inject({}) do |h, remote_ip|
        h[remote_ip] = @data.select { |p| p.transit_ip_address == remote_ip }.size
        h
      end
    end

    private

    def remote_ips
      @remote_ips ||= @data.collect(&:transit_ip_address).uniq
    end

    def locations
      @locations ||= @data.collect(&:metro).uniq
    end
  end

  class StatisticFromRawPostings < StatisticFromPostings
    def initialize(timestamp1, timestamp2)
      @data = RawPosting.rejected.where("created_at >= ? and created_at < ?", timestamp1, timestamp2)
    end

    def num_rejected
      @data.size
    end

    def num_by_auth_token
      auth_tokens.inject({}) do |h, token|
        h[token.to_s] = @data.where(auth_token: token).count
        h
      end
    end

    private

    def auth_tokens
      @auth_tokens ||= @data.collect(&:auth_token).uniq
    end
  end

  def send_stats
    key = :postings_processed
    data = { group: key}

    if self.data[key]
      data.merge!(self.data[key])
      #RestClient.post(STATS_URL, data)
      post_data = Net::HTTP.post_form(URI.parse(STATS_URL), data)
      SULO8.info post_data.body
    end
  end
end
