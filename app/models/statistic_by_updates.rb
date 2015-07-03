class StatisticByUpdates < StatisticBase
  self.table_name = 'statistic_by_updates'

  REDIS_KEY_REGEXP = /^updates:(\w{5}):(\w{4}):([\d\-]{10})$/

  class << self
    def get_data_for(date = (Date.today - 1.day))

      data = (date == Date.today) ? get_data_from_redis(date) : get_data_from_db(date)

      #sort by source counts
      data = data.sort_by { |_, v| -v.values.sum }

      #sort by category counts
      data.each { |v| v[1] = v.last.sort_by { |_,count| -count } }
    end

    def get_data_by_source(date, source, redis = RedisHelper.get_redis)
      if date == Date.today
        redis_updated_keys = RedisHelper.scan_for_stats_key("updates:#{source}:*:#{date}", redis)
        redis_updated_value.any? ? redis.mget(redis_updated_keys).reduce(0) {|sum, key|  sum + key.to_i } : 0
      else
        where(for_date: date, source: source).sum(:count)
      end
    end

    def flush_to_db
      redis = RedisHelper.get_redis
      keys = RedisHelper.scan_for_stats_key("updates:*:*:*", redis)
      keys = keys.select {|i| i =~ REDIS_KEY_REGEXP }

      RedisHelper.mget_zip(keys, redis).each do |key, value|
        _, source, category, date = key.split(':')
        date = Time.parse(date).strftime("%Y-%m-%d")

        record = find_or_initialize_by(for_date: date, source: source, category: category)
        record.count = record.count.nil? ? value.to_i : record.count + value.to_i
        record.save!
      end
      redis.del keys
      redis.del "updated_postings:origins:#{ Date.today - 2.days}"
    end

    private

    def get_data_from_redis(date, data = {})
      redis = RedisHelper.get_redis
      keys = RedisHelper.scan_for_stats_key("updates:*:*:#{ date }", redis)
      RedisHelper.mget_zip(keys).each do |key, value|
        next unless key =~ REDIS_KEY_REGEXP
        _, source, category, _date = key.split(':')
        amount = value.to_i
        set_source_category_amount(data, source, category, amount) if amount > 0
      end
      data
    end

    def get_data_from_db(date, data = {})
      where(for_date: date).each do |entity|
        source, category, amount = entity.source, entity.category, entity.count

        set_source_category_amount(data, source, category, amount)
      end
      data
    end

    def set_source_category_amount(data = {}, source, category, amount)
      data[source] = {} unless data.has_key?(source)

      if data[source].has_key?(category)
        data[source][category] += amount
      else
        data[source][category] = amount
      end
    end
  end
end
