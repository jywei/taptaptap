class StatisticByMetro < StatisticBase
  REDIS_KEY_REGEX = /^metro_categories:([\d\-:]+):([\w]{4})$/

  class << self
    def get_data(date)
      if date < Date.today
        data = select("count, metro, category").where(for_date: date).group_by { |e| e[:metro] }
        res = {}
        if data
          data.each do |metro, counts|
            present = counts.map { |e| e.attributes.symbolize_keys }

            without_cats = PostingConstants::MCR_CATEGORIES - present.map{|e| e[:category]}

            all = present + without_cats.map{|e| {category: e, count: 0}}

            res[metro] = all.sort_by{|e| e[:category]}
          end
        end

        Hash[res.sort_by{|k,_| k}]
       else
        redis = RedisHelper.get_redis
        keys = RedisHelper.scan_for_stats_key("metro_categories:#{Date.today}:*", redis)
        res = {}

        keys.each do |key|
          data = redis.hgetall key
          _, category = REDIS_KEY_REGEX.match(key).captures

          data.each do |metro, count|
            res[metro] = Hash[PostingConstants::MCR_CATEGORIES.sort.map { |cat| [cat, 0] }] unless res.has_key? metro

            if res[metro].has_key? category
              res[metro][category] += count.to_i
            else
              res[metro][category] = count.to_i
            end
          end
        end

        result = {}

        res.each do |metro, stats|
          result[metro] = stats.map { |category, count| { category: category, count: count } }
        end

        Hash[result.sort_by{|k,_| k}]
      end
    end

    def flush_to_db
      redis = RedisHelper.get_redis
      keys = RedisHelper.scan_for_stats_key("metro_categories:*", redis).select { |k| Time.parse(k.gsub(REDIS_KEY_REGEX, '\1')) < Date.today.beginning_of_day }

      keys.each do |key|
        data = RedisHelper.get_redis.hgetall key
        date, category = REDIS_KEY_REGEX.match(key).captures

        data.each do |metro, count|
          entry = where(for_date: date, category: category, metro: metro)

          if entry.present?
            entry.update_attribute count: (entry.count + count)
          else
            create(for_date: date, category: category, metro: metro, count: count)
          end
        end
      end
      RedisHelper.get_redis.del keys
    end

    def track(metro, category)
      redis = RedisHelper.hiredis
      metro = metro[-3..-1] if metro.size > 3

      if PostingConstants::MCR_CODES.include?(metro) && PostingConstants::MCR_CATEGORIES.include?(category)
        redis.write [ 'hincrby', "metro_categories:#{Date.today}:#{category}", metro, 1 ]
        redis.read
      end

      # if posting[:location].present? and posting[:location][:metro].present?
      #   metro = posting[:location][:metro]
      # elsif posting[:metro].present?
      #   metro = posting[:metro]
      # else
      #   return
      # end
    end
  end
end

