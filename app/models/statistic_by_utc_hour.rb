class StatisticByUtcHour < StatisticBase
  class << self
    def get_data(date)
      RedisHelper.get_redis.smembers('transit_ip_address').map do |ip|
        {
            name: ip,
            data: where(for_date: date, ip_address: ip).pluck("utc_hour, count")
        }
      end
    end
  end
end
