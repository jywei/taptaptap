class Statistics
  POSTING_VALIDATION = "Custom/Posting/validate"
  BACKGROUND_TIME = "OtherTransaction/ResqueJob/BatchGeoApiWorker/perform"
  POSTING_INSERT = "Database/SQL/insert"
  POSTING_RESPONDING = "Custom/Posting/responding"
  GEO_STATS = "GeoApi/Stats"
  AVAILABLE_POSTINGS = "Postings/Available"

  def self.current_timestamp
    DateTime.now.beginning_of_minute.to_i
  end

  class Tracker
    def self.trace(key, &block)
      timing = Benchmark.measure &block
      # Tracker.add(key, (timing.real*1000).round)
    end

    def self.add(key, value)
      timestamp = Statistics.current_timestamp

      current_value = RedisHelper.get_redis.get(timestamp)

      begin
        current_value = current_value ? JSON.parse(current_value) : {}
      rescue Exception => e
        SULOEXC.error "Could not parse JSON (#{current_value.inspect}) for #{current_value} because of exception #{e.message} in #{e.backtrace.join "\n" }"
        current_value = {}
      end

      current_value[key] ||= []
      current_value[key] << value

      RedisHelper.get_redis.set timestamp, current_value.to_json
    end
  end
end
