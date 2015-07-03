class StatisticByEmptyImage < StatisticBase
  class << self
    def track(posting)
      posting[:images].select!{|e| e.present? && (e["full"].present? || e["thumb"].present?) }

      if posting[:images].blank?
        p posting[:id]
        RedisHelper.get_redis.incr("empty_images:#{posting[:source]}:#{posting[:category]}:#{posting[:created_at].to_date}")
      end
    end

    def flush_to_db
      redis = RedisHelper.get_redis

      keys = RedisHelper.scan_for_stats_key("empty_images:*", redis)

      keys.each do |key|
        _e, source, category, date = key.split(":")
        amount = redis.get(key)

        record = find_or_initialize_by(source: source, category: category, for_date: date)
        record.amount = record.amount.to_i + amount.to_i
        record.save!
      end
      redis.del keys
    end
  end
end