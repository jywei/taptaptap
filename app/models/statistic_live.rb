class StatisticLive
  SERIES_LENGTH = 30

  class << self
    def save_to_db
      time = Time.now.beginning_of_hour.to_i
      t1 = time - 3600
      redis = RedisHelper.get_redis

      PostingConstants::SOURCES.each do |source|
        keys = (0..59).map {|i| "#{source}:added:#{t1 + i.minutes}"}
        values = keys.any? ? redis.mget(keys) : []
        count = values.reduce(0) {|sum, val| sum + val.to_i }

        stat = StatisticBySource.find_or_initialize_by source: source, utc_hour: Time.now.utc.strftime('%H'), for_date: Time.at(t1).strftime("%Y-%m-%d"), deleted: false
        stat.count = count
        stat.save!


        keys = (0..59).map {|i| "#{source}:deleted:#{t1 + i.minutes}"}
        values = keys.any? ? redis.mget(keys) : []
        count = values.reduce(0) {|sum, val| sum + val.to_i }

        stat = StatisticBySource.find_or_initialize_by source: source, utc_hour: Time.now.utc.strftime('%H'), for_date: Time.at(t1).strftime("%Y-%m-%d"), deleted: true
        stat.count = count
        stat.save!
      end
    end

    def get_data(last_hours = 1, time = Time.now.utc.to_i)
      t1 = Time.at(time).beginning_of_hour.to_i - last_hours.hours

      hour = Time.at(time).hour

      PostingConstants::SOURCES.collect do |source|
        if last_hours > 1
           counts = StatisticBySource.
               where("utc_hour > #{hour - last_hours}").
               where(source: source, for_date: Time.at(time).
               strftime('%Y-%m-%d')).
               pluck('count')

           if counts.size > 0 and counts.last.first < hour - 1
             counts << get_last_hour_counts_for(source, time - 1.hour)
           end
        else
          counts = get_last_hour_counts_for source, time
        end

        {
            id: "series-#{ source.is_a?(Array) ? source.last.downcase : source.downcase }",
            name: source,
            data: counts
        }
      end
    end

    def get_total_data_by(criteria)
      counts = StatisticByHeartbeat.get_heartbeats_for criteria

      [{ id: "total-series-by-#{ criteria }", name: "total_by_#{ criteria }", data: counts }]
    end

    def get_sorted_data(*args)
      send(:get_data, *args).sort { |a, b| b[:data].first <=> a[:data].first }
    end

    def get_data_1_day(time)
      t1 = time - 1.day # to get last 24 hours
      t2 = t1 / 100_000 # to get keys from redis

      data = []
      redis = RedisHelper.get_redis

      PostingConstants::SOURCES.collect do |source|
        pattern = "#{source}:added:#{t2}*"
        keys = RedisHelper.scan_for_stats_key(pattern, redis).select{ |key| key.split(':').last.to_i >= t1 }
        values = keys.any? ? redis.mget(keys) : []
        count = values.inject(0) { |sum, key| sum += key.to_i }

        {
            id: "series-#{ source.downcase }",
            name: source,
            data: []
        }
      end
    end

    def get_last_hour_counts_for(source, time)
      t1 = time / 3600 * 3600 # getting hourly timestamp
      redis = RedisHelper.get_redis
      keys = (0..Time.at(time).min).map {|i| "#{source}:added:#{t1 + i.minutes}"}
      values = keys.any? ? redis.mget(keys) : []

      counts = values.inject(0) { |sum, value| sum += value.to_i}

      [ counts ]
    end
  end
end
