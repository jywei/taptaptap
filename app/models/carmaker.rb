class Carmaker
  class << self

    def track(make, source)
      redis = RedisHelper.hiredis
      redis.write ['hset', "carmakers:#{ source }", make.strip, Time.now]
      redis.read
    end

    def get_data(source)
      present = RedisHelper.get_redis.hgetall("carmakers:#{ source }")

      all_by_source = all_makers(source)

      p all_by_source
      {
        present: present,
        missing: (all_by_source["makers"] - present.keys)
      }
    end

    private

    def all_makers(source)
      if source != "HMNGS"
        file = File.open("lib/data/carmakers/#{source}.json", "r")
        data = file.read
        file.close
        JSON.parse(data)
      else
        {"makers" => []}
      end
    end

  end
end