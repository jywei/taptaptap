class LatencyHourlyStatistic < StatisticBase
  class << self

    def hourly(hour = (Time.now - 1.hour).beginning_of_hour)
      format_for_chart( where(for_hour: hour) )
    end

    def daily(for_day = Time.now.utc.beginning_of_day)
      format_for_chart( get_latencies(for_day, :day))  
    end

    def monthly(for_month = Time.now.utc.beginning_of_month)
      format_for_chart( get_latencies(for_month, :month) )    
    end

    def day_hourly(for_day = Time.now.utc.beginning_of_day)
      q_by_source = <<-SQL
            SELECT 
                source,DATE_FORMAT(for_hour, '%Y-%m-%d %H:%i') as for_hour, latency
            FROM
                latency_hourly_statistics
            WHERE
                for_hour >= '#{for_day.to_s(:db)}' AND for_hour < '#{(for_day + 1.day).to_s(:db)}'
            GROUP BY 
              source, for_hour
            ORDER BY
              source   
          SQL

      rows = connection.select_all(q_by_source).to_hash
      rows = rows.group_by{|e| e["source"]}

      q_total = <<-SQL
            SELECT 
                DATE_FORMAT(for_hour, '%Y-%m-%d %H:%i') as for_hour, ROUND(AVG(latency), 2) as latency
            FROM
                latency_hourly_statistics
            WHERE
                for_hour >= '#{for_day.to_s(:db)}' AND for_hour < '#{(for_day + 1.day).to_s(:db)}'
            GROUP BY for_hour                 
          SQL

      rows["total"] = connection.select_all(q_total).to_hash   
      
      res = {}
      rows.each do |title, data|
        res[title] =  format_for_chart(data, "for_hour")
      end 
      res
    end  


    def clean_old(created_at)
      connection.execute("DELETE from latency_hourly_statistics where for_hour < '#{created_at}';")
    end  

    private

    def get_latencies(for_date, type)
      q = <<-SQL
            SELECT 
                source, ROUND(AVG(latency), 2) as latency
            FROM
                latency_hourly_statistics
            WHERE
                for_hour >= '#{for_date.to_s(:db)}' AND for_hour < '#{(for_date + 1.send(type)).to_s(:db)}'
            GROUP BY source                 
          SQL
          
      connection.select_all(q).to_hash
    end

    def format_for_chart(data, x = "source")
      [{
        name: "latency",
        data: data.map{|e| [e[x], e["latency"]]}
      }] 
    end  
  end
end
