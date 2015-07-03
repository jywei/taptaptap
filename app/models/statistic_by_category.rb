class StatisticByCategory < StatisticBase
  def self.get_data(date, category_group="VVVV")
    RedisHelper.get_redis.smembers('transit_ip_address').map do |ip|
      {
          name: ip,
          data: where(for_date: date, ip_address: ip, category_group: category_group).pluck("category, count")
      }
    end
  end
end
