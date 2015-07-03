class LiveLovely
  class << self

    def track(annotations, price = nil)
      date = Date.today

      @redis = RedisHelper.hiredis
      @reads = 0

      if price
        @redis.write ["hincrby live_lovely:#{date}", "price", 1 ]
        @reads += 1
      end

      if annotations.present?
        if annotations.include?('source_account')
          @redis.write ["hincrby live_lovely:#{date}", "source_account", 1 ]
          @reads += 1
        end

        if annotations.include?('formatted_address')
          @redis.write ["hincrby live_lovely:#{date}", "formatted_address", 1 ]
          @reads += 1
        end

        if annotations.include?('bedrooms') || annotations.include?('beds')
          @redis.write [ "hincrby live_lovely:#{date}", "bedrooms", 1 ]
          @reads += 1

          if  price && annotations.include?('source_account') && annotations.include?('formatted_address')
            @redis.write [ "hincrby live_lovely:#{date}", "together", 1 ]
            @reads += 1
          end
        end
      end

      @reads.times { |_| @redis.read }
    end

    def get_data(start_date, end_date)
      res = []

      start_date.upto(end_date) do |date|
        data = RedisHelper.get_redis.hgetall("live_lovely:#{date}")

        res << { date: date, data: data } if data.present?
      end

      res.sort_by { |e| e[:date] }.reverse if res.present?
    end
  end
end