class StatisticByLongTerm < StatisticBase
  class << self
    def get_data(date)
      {
          prev_week: get_prev_week_avg_data(date),
          prev_month: get_prev_month_avg_data(date),
          august: get_month_avg_data(8)
      }
    end

    private

    def get_month_avg_data(month)
      start_date = Date.new(2014, month, 1)
      end_date = start_date + 1.month

      avg_data(start_date, end_date)
    end

    def get_prev_week_avg_data(date)
      end_date = date.at_beginning_of_week
      start_date = end_date - 1.week

      avg_data(start_date, end_date)
    end

    def get_prev_month_avg_data(date)
      end_date = date.at_beginning_of_month
      start_date = end_date - 1.month

      avg_data(start_date, end_date)
    end

    def avg_data(start_date, end_date)
      RedisHelper.get_redis.smembers('transit_ip_address').map do |ip|
        q = <<-SQL
              SELECT
                  ip_address, utc_hour, ROUND(AVG(`count`)) AS avg_count
              FROM
                  statistic_by_utc_hours
              WHERE
                  for_date >= '#{ start_date }' AND for_date < '#{ end_date }' AND ip_address = '#{ip}'
              GROUP BY utc_hour
        SQL

        res = connection.select_all(q).to_hash

        {
            name: ip,
            data: res.map{ |row| [ row['utc_hour'], row['avg_count'] ] }
        }
      end
    end
  end
end
