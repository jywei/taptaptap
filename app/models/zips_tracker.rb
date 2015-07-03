class ZipsTracker
  MAGIC_RETRY_COUNT = 10

  COUNTRIES_ZIPS_REGEXP =
  {
    "CAN" => /^[abceghjklmnprstvxyABCEGHJKLMNPRSTVXY][0-9][abceghjklmnprstvwxyzABCEGHJKLMNPRSTVWXYZ]\s?[0-9][abceghjklmnprstvwxyzABCEGHJKLMNPRSTVWXYZ][0-9]/,
    "UK" => /^([A-PR-UWYZa-pr-uwyz0-9][A-HK-Y0-9][AEHMNPRTVXYaehmnprtvxy0-9]?[ABEHMNPRVWXYabehmnprvwxy0-9]? {1,2}[0-9][ABD-HJLN-UW-Zabd-hjln-uw-z]{2}|GIR 0AA)$/,
    "USA" => /^\d{5}(-\d{4})?$/
  }

  class << self
    def track(zip, source, state, category_group, redis)
      redis = RedisHelper.hiredis unless redis

      res = /(\d{3,6})/.match(zip.to_s)
      zip = res.to_a.first if res

      retry_count = 0

      begin
        #save only USA zip codes for map
        if state.present?
          state = state[-2..-1] if state.size > 2
        else
          state = "OT" #other state
        end

        # redis.write ["HINCRBY", "stats:zips_postings:#{ source }:#{ category_group }:#{state}:#{ Date.today }:#{ Time.now.hour }", zip, 1]
        redis.write ["HSET", "stats:zips:#{ source }", zip, Time.now]
        redis.read
        # redis.read
      rescue Redis::TimeoutError => e
        retry_count += 1

        if retry_count < MAGIC_RETRY_COUNT
          sleep 1.0 / 100

          retry
        else
          raise e
        end
      end
    end

    def track_empty(redis)
      retry_count = 0

      begin
        #save only USA zip codes for map
        redis.write ["INCR", "stats:zips_postings_empty:#{ Date.today }:#{ Time.now.hour }"]
        redis.read
      rescue Redis::TimeoutError => e
        retry_count += 1

        if retry_count < MAGIC_RETRY_COUNT
          sleep 1.0 / 100

          retry
        else
          raise e
        end
      end
    end

    def check_params(params)
      errors = []

      errors << "parameter 'source' is required"  unless params.has_key?(:source)

      errors << "'source' should be one from: #{ Posting::SOURCES.join(", ") }"  unless Posting::SOURCES.include? params[:source]

      errors << "'hours' should be a number" if params.has_key?(:hours) && !/^\d*$/.match(params[:hours])

      errors << "'amount' should be a number" if params.has_key?(:amount) && !/^\d*$/.match(params[:amount])

      errors << "'country' should be one from: #{ COUNTRIES_ZIPS_REGEXP.keys.join(", ") }" if params.has_key?(:country) && !COUNTRIES_ZIPS_REGEXP.has_key?(params[:country])

      errors
    end

    def get_zips(source)
      zips = {}

      zips[:present] = RedisHelper.get_redis.hgetall("zips:#{ source }")
      zips[:missing] = all_zips - zips[:present].keys

      zips
    end

    def present_zips(source)
      RedisHelper.get_redis.hgetall("zips:#{ source }")
    end

    def old_date_zips(params)
      errors = check_params(params)

      return { success: false, error: errors.join(",") } if errors.present?

      num_hours = (params[:hours] || 24).to_i

      time = Time.now - num_hours.hours

      zips = present_zips(params[:source])

      res = {}

      amount = (params[:amount] || 100).to_i

      if params[:country]
        data = zips.select{ |zip, date| COUNTRIES_ZIPS_REGEXP[params[:country]].match(zip) && DateTime.parse(date) < time }
      else
        data = zips.select{ |zip, date| DateTime.parse(date) < time }
      end

      res[:old_date_zips] = data.sort_by{|_,date| date}.take(amount).map(&:first)

      if params[:never_received] && params[:never_received].downcase == 'true'
        res[:never_received] = (all_zips - zips.keys).sort
      end

      res
    end

    #only USA zips for map
    def get_counts(date, hours = nil, source = nil, state = nil, no_rrrr = 'true')
      redis = RedisHelper.get_redis
      keys = []

      patterns = hours[:from].to_i.upto(hours[:to].to_i).map do |hour|
        "zips_postings:#{ source || '*' }:*:#{ state || '*' }:#{ date }:#{ hour }"
      end
      keys = patterns.any? ? redis.mget(patterns) : []

      SULO8.info "WORKING ON #{keys.size} KEYS"

      result = {}
      total_postings = 0
      other_cities = 0

      keys.each do |key|
        next if no_rrrr && key.include?("RRRR")

        key_re = /^zips_postings:[A-Z_]{5}:[A-Z]{4}:([A-Z]{2}):[\d\-.]+:\d+$/

        next unless key =~ key_re

        zips = redis.hgetall(key)
        state_key = key.gsub(key_re, '\1')

        zips.each do |zip, count|
          count = count.to_i
          total_postings += count

          unless zips_with_lat_long.has_key?(zip)
            other_cities += count
            next
          end

          next unless states.has_key? state_key

          if result.has_key? zip
            result[zip][:postings] += count
          else
            result[zip] = {
                postings: count,
                lat: zips_with_lat_long[zip]["lat"],
                lon: zips_with_lat_long[zip]["long"],
                metro: zips_with_lat_long[zip]["metro"],
                state: states[state_key]["name"],
                code: state_key,
                zipcode: zip,
                radius: 0
            }
          end
        end
      end

      data = result.values

      data << {
          postings: other_cities,
          lat: nil,
          lon: nil,
          state: states['OT']['name'],
          code: 'OT',
          zipcode: '****',
          radius: 0
      }

      data
    end

    def get_empties_counts(date, hours = nil)
      redis = RedisHelper.get_redis

      if hours.present? and hours.is_a? Hash and hours.has_key? :from and hours.has_key? :to
        patterms = hours[:from].to_i.upto(hours[:to].to_i).map  do |hour|
          "zips_postings_empty:#{ date }:#{ hour }"
        end
        keys = patterns.any? ? redis.mget(patterns) : []
      else
        keys = RedisHelper.scan_for_stats_key "zips_postings_empty:#{ date }:*", redis
      end

      values = keys.any? ? redis.mget(keys) : []

      keys.reduce(0) { |sum, key| sum += key.to_i }
    end

    def delete_old_redis_keys
      redis = RedisHelper.hiredis
      keys = RedisHelper.scan_for_key 'stats:zips_postings:*', redis

      reads = 0

      re = /^stats:zips_postings:[A-Z]{5}:[A-Z]{4}:[\w]{2}:([\d\-.]+):\d+$/
      reads += keys.select { |key| key =~ re }.each { |key| redis.write [ 'del', key ] if Time.parse(key.gsub(re, '\1')) < Time.now - 1.week }.size

      re = /^stats:zips_postings:[A-Z]{5}:([\d\-.]+):\d+$/
      reads += keys.select { |key| key =~ re }.each { |key| redis.write [ 'del', key ] if Time.parse(key.gsub(re, '\1')) < Time.now - 1.week }.size

      reads.times { |_| redis.read }
    end

    def zip
      @zip if @zip.present?

      @zip = JSON.parse(File.read(File.join(Rails.root, 'lib', 'data', 'us-topo.json')))
    end

    #dont rename this method
    def states
      @states if @states.present?

      @states = JSON.parse(File.read(File.join(Rails.root, 'lib', 'data', 'states.json')))
    end

    # for test only
    # when it won't need -- remove thid method and files in lib/data/zips_by_states
    def state(state_code)
      filename = File.join(Rails.root, 'lib', 'data','zips_by_states', "#{state_code}.json")

      return {} unless File.exist? filename

      JSON.parse(File.read(filename))
    end

    private

    def all_zips
      zips_with_lat_long.keys
    end

    def zips_with_lat_long
      @zips_with_lat_long ||= get_zips_with_lat_long
    end

    def get_zips_with_lat_long
      data = File.read("lib/data/zips_with_lat_long.json")
      JSON.parse(data)
    end
  end
end
