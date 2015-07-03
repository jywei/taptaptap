class StatisticByCategoryGroup < StatisticByCategory
  def self.get_data(date)
    RedisHelper.get_redis.smembers('transit_ip_address').map do |ip|
      {
          name: ip,
          data: where(for_date: date, ip_address: ip).group(:category_group).pluck("category_group, sum(count)")
      }
    end
  end
end
