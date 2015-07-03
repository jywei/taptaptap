class StatisticByIpOnDates < StatisticByDate
  def self.get_data(date)
    RedisHelper.get_redis.smembers('transit_ip_address').map do |ip|
      {
        name: ip,
        data: where(for_date: date, ip_address: ip).order(:date).pluck("date, count")
      }
    end
  end
end
