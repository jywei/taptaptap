class StatisticByDatesOnIp < StatisticByDate
  # non-AR model
  def self.get_data(date)
    dates = where(for_date: date).pluck(:date).uniq
    ips = RedisHelper.get_redis.smembers('transit_ip_address')

    dates.map do |for_date|
      data = where(for_date: date, ip_address: ips, date: for_date).pluck('ip_address, count')

      { name: for_date, data: data }
    end
  end
end
