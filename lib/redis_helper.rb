class RedisHelper
  if Rails.env.production?
    # REDIS_CONFIG = { host: 'localhost', port: 6379 }
    REDIS_CONFIG = { path: '/tmp/redis.sock' }
  elsif Rails.env.staging?
    REDIS_CONFIG = { host: 'localhost', port: 6380 }
  elsif Rails.env.development?
    REDIS_CONFIG = { host: 'localhost', port: 6379 }
  elsif Rails.env.test?
    REDIS_CONFIG = { host: 'localhost', port: 6379 }
  end

  @@connection = Redis.new(REDIS_CONFIG)
  @@redis = Redis::Namespace.new(:stats, :redis => @@connection)

  class << self
    def existing_redis
      @@redis
    end

    def hiredis
      hiredis_conn = Hiredis::Connection.new

      if Rails.env.production?
        hiredis_conn.connect_unix("/tmp/redis.sock")
      else
        hiredis_conn.connect(REDIS_CONFIG[:host], REDIS_CONFIG[:port])
      end

      hiredis_conn
    end

    def get_redis
      # raise 'No Redis in test env' if Rails.env.test?

      begin
        @@redis.ping
      rescue
        logger = ActiveRecord::Base.logger
        logger.warn('Redis connection was bad. Re-establishing...')
        @@connection = Redis.new(REDIS_CONFIG)
        @@redis = Redis::Namespace.new(:stats, :redis => @@connection)
      end

      @@redis
    end

    # run on 1st day of mon!
    def delete_old_keys
      # patterns:
      # RedisHelper.get_redis.incr "#{date_now}:#{time.strftime("%H")}:#{request.remote_ip}"
      # RedisHelper.get_redis.incr "#{date_now}:#{posting[:category]}:#{request.remote_ip}"
      # RedisHelper.get_redis.incr "#{date_now}:#{posting[:category_group]}:#{request.remote_ip}"
      # RedisHelper.get_redis.incr "#{date_now}:#{Time.at(posting[:timestamp]).strftime("%Y-%m-%d")}:#{request.remote_ip}"
      # RedisHelper.get_redis.incr "CRAIG:added:#{time.to_i / 60 * 60}" # keys tied to minutely timestamps
      # RedisHelper.get_redis.sadd 'transit_ip_address', ip

      redis = RedisHelper.hiredis

      date = Date.today - 1.month # leave 1 month of stats in redis
      old_keys = RedisHelper.scan_for_key "#{date.strftime("%Y-%m")}:*", redis
      old_keys.each { |key| redis.write [ 'del', key ] }
      old_keys.size.times { |_| redis.read }

      #Posting::SOURCES.each do |source|
      #  get_redis.keys("#{source}:added:*").each { |key| get_redis.del key if key.split(':').last.to_i < time.to_i }
      #end
      keys = RedisHelper.scan_for_key '*:added:*', redis

      old_keys = keys.select { |e| e =~ /^total:added:.*$/}.select {|e| Time.parse(e.gsub(/^total:added:((second|minute|hour|day):)?(\d+\.\d+\.\d+).*$/, '\3')) < (Time.now - 2.days) }
      old_keys.map { |e| redis.write [ 'del', e ] }
      old_keys.size.times { |_| redis.read }

      old_keys = keys.select { |e| e =~ /^([A-Z]{5}):added:(\d+)$/}.select {|e| Time.at(e.gsub(/^([A-Z]{5}):added:(\d+)$/, '\2').to_i) < (Time.now - 2.days) }
      old_keys.map { |e| redis.write [ 'del', e ] }
      old_keys.size.times { |_| redis.read }

      keys = RedisHelper.scan_for_key "stats:CRAIG:deleted:*", redis
      old_keys = keys.select { |key| key.split(':').last.to_i < (Time.now - 2.days).to_i }
      old_keys.map { |k| redis.write [ 'del', k ] }
      old_keys.size.times { |_| redis.read }

      keys = RedisHelper.scan_for_key "stats:*:empty_timestamp_ids:*", redis
      old_keys = keys.select { |key| Time.parse(key.split(':')[1]) < (Time.now - 2.days) }
      old_keys.map { |k| redis.write [ 'del', k ] }
      old_keys.size.times { |_| redis.read }

      true
    end

    def scan_for_key(key, redis =  RedisHelper.hiredis)
      redis.write(["scan", "0", "match", key])
      count, result = redis.read
      while count != "0"
        redis.write(["scan", count, "match", key])
        count, new_result = redis.read
        result = result.concat(new_result)
      end
      result.uniq
    end

    def scan_for_stats_key(key, redis =  RedisHelper.get_redis)
      count, result = redis.scan(0, match: key)
      while count != "0"
        count, new_result = redis.scan(count.to_i, match: key)
        result = result.concat(new_result)
      end
      result.uniq
    end

    def mget_zip(keys, redis = RedisHelper.get_redis)
      keys.any? ? keys.zip(redis.mget(keys)) : []
    end
  end
end
