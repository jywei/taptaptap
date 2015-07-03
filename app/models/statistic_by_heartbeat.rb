class StatisticByHeartbeat < StatisticBase
  class << self
    def get_heartbeats_for(criteria)
      time_start =
          case criteria
            when :day then Time.now.at_beginning_of_month
            when :hour then Time.now.at_beginning_of_day
            when :minute then Time.now.at_beginning_of_hour
            else Time.now - 1.second
          end

      time_end = Time.now

      step = 1.send(criteria)

      formats = { day: '%d.%m.%Y', hour: '%d.%m.%Y:%H', minute: '%d.%m.%Y:%H:%M', second: '%d.%m.%Y:%H:%M:%S' }
      format = formats[criteria]
      counts = []

      (time_start.to_i .. time_end.to_i).step(step) do |time|
        time = Time.at(time)
        # note: here we're using non-utc time for string time representation on frontend
        str_key = time.strftime('%b %d, %Y %H:%M:%S')

        if (criteria == :day and time < Time.now.at_beginning_of_day) or (criteria == :hour and time < Time.now - 1.hour)
          count = select('SUM(count) AS count').where(for_timestamp: time, criteria: criteria).first['count']
        else
          count = RedisHelper.get_redis.get("total:added:#{ criteria }:#{ time.strftime(format) }").try(:to_i)
        end

        counts << [ str_key, (count || 0) ]
      end

      counts.uniq { |e| e[0] }
    end

    def get_daily_heartbeats_for(time_start, time_end)
      counts = []

      (time_start.to_i .. time_end.to_i).step(1.day) do |time|
        time = Time.at(time)

        # note: here we're using non-utc time for string time representation on frontend
        str_key = time.strftime('%b %d, %Y %H:%M:%S')

        count = where(for_date: time).first.count

        counts << [ str_key, count ]
      end
    end

    def flush_to_db
      time = Time.now - 1.hour
      redis = RedisHelper.get_redis

      Parallel.each([ :hour, :minute, :second, :day ], :in_threads => 4) do |criteria|
        time = Date.today.beginning_of_day if criteria == :day
        keys = RedisHelper.scan_for_stats_key("total:added:#{criteria}:*", redis)

        if keys.any?
          add_or_update_record(keys, criteria, time, redis)
        end
      end
    end

    private

    def add_or_update_record(keys, criteria, time, redis = RedisHelper.get_redis)
      RedisHelper.mget_zip(keys, redis).each do |key, value|
        redis_timestamp = Time.parse(key.gsub(/^total:added:#{ criteria }:(\d+\.\d+\.\d+).*$/, '\1'))
        binding.pry

        if (criteria == :second) and (redis_timestamp < time)
          RedisHelper.get_redis.del key
          next
        end

        if redis_timestamp < time
          create_or_update_record(redis_timestamp, criteria, value)
        end
      end
    end

    def create_or_update_record(redis_timestamp, criteria, value)
      record = find_or_initialize_by(for_timestamp: redis_timestamp, criteria: criteria)
      record.count = record.count.nil? ? value.to_i : record.count + value.to_i
      record.save!
    end

  end
end
