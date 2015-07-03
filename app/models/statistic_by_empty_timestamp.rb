class StatisticByEmptyTimestamp
  def self.get_data(start_date, end_date)
    (start_date .. end_date).map do |date|
      redis_key = "#{date.strftime("%Y-%m-%d")}:empty_timestamp:CRAIG"

      [ date.strftime("%Y-%m-%d"), RedisHelper.get_redis.get(redis_key) ]
    end
  end

  def self.get_empty_ids(date)
    keys = RedisHelper.get_redis.hkeys("#{date}:empty_timestamp_ids:CRAIG")

    if keys.present?
      keys.map do |key|
        {
          id: key,
          external_url: RedisHelper.get_redis.hget("#{date}:empty_timestamp_ids:CRAIG", key)
        }
      end
    end
  end
end
