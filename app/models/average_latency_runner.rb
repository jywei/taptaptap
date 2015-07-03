class AverageLatencyRunner
  class << self 

    def save_hourly_latency
      last_saved_hourly = LatencyHourlyStatistic.last

      if last_saved_hourly
        start_hour = last_saved_hourly.for_hour
      else
        start_hour = (Time.now.utc - 1.hour).beginning_of_hour
      end  
      
      Posting.table_name = "postings#{ Posting2.current_volume }"
      first_current_creted_at = Posting.order(:created_at).limit(1).pluck(:created_at).first.beginning_of_hour
      
      while start_hour < first_current_creted_at 
        get_and_save_average_latency(start_hour, start_hour + 1.hour)
        start_hour += 1.hour  
      end  
        
    end

    def fill
      first, last =  StatisticByLatency.first, StatisticByLatency.last

      start_hour = first.posting_created_at.beginning_of_hour
      next_hour = start_hour + 1.hour

      while next_hour <= last.posting_created_at

        get_and_save_average_latency(start_hour, next_hour)

        start_hour = next_hour
        next_hour = start_hour + 1.hour  
      end  

    end

    def get_and_save_average_latency(start_hour, next_hour)
      q = <<-SQL
          SELECT 
              source, AVG(latency) as a_latency
          FROM
              statistic_by_latencies
          WHERE
              posting_created_at >= '#{ start_hour }' AND posting_created_at < '#{ next_hour }' AND latency != 0
          GROUP BY source                 
        SQL

        averages = StatisticByLatency.connection.select_all(q).to_hash

        if averages.present?
          averages.each do |avg|
            row = LatencyHourlyStatistic.find_or_create_by(
                    {
                      source: avg["source"],
                      for_hour: start_hour
                    })

            row.update_attributes({ latency: avg["a_latency"] })

          end  
        end
    end

  end  
end  