class StatisticByTransferedData < PaymentBase
  self.table_name = 'statistic_by_transfered_data'

  scope :posting, -> { where(direction: 'in') }
  scope :polling, -> { where(direction: 'out') }
  scope :search, -> { where(direction: 'search') }

  scope :last_month, -> { where("for_date >= ? AND for_date < ?",  (Time.now - 1.month).at_beginning_of_month, Time.now.at_beginning_of_month) }
  scope :this_month, -> { where("for_date >= ? AND for_date <= ?", Time.now.at_beginning_of_month, Time.now) }

  class << self
    def get_data(params)
      raise "No params given to fetch statistics" unless params.is_a? Hash

      permitted_keys = [ :source, :category_group, :ip, :auth_token, :direction, :for_date ]

      params = params.select { |k, _| permitted_keys.include? k }

      rows = where(params).order(:for_date)

      rows.group_by(&:for_date).map do |date, row|
        Hash[ [["date", "#{date}"]] + row.map{|e| [e.category_group, { amount: e.amount, bytes: e.data_size }]} ]
      end
    end

    def track(params)
      raise "No params given to track statistics" unless params.is_a? Hash

      permitted_keys = [ :source, :category, :ip, :auth_token, :direction, :amount, :redis_connection, :data_size ]

      params = params.select { |k, _| permitted_keys.include? k }

      direction = params[:direction]
      source = params[:source]
      category = params[:category]
      auth_token = params[:auth_token]
      ip = params[:ip]
      date = Time.now.utc.to_date
      postings_amount = (params[:amount] || 1).to_i
      data_size = (params[:data_size] || 0).to_i

      if params.has_key? :redis_connection
        redis = params[:redis_connection]
      else
        redis = RedisHelper.hiredis
      end

      redis.write [ "incrby", "stats:transfered_data:#{ direction }:#{ source }:#{ category }:#{ auth_token }:#{ ip }:#{ date }", postings_amount ]
      redis.write [ "incrby", "stats:transfered_bytes:#{ direction }:#{ source }:#{ category }:#{ auth_token }:#{ ip }:#{ date }", data_size ]
      redis.read
      redis.read
    rescue Exception => e
      SULOEXC.error "<StatisticByTransferedData> #{e.message}"
    end

    def flush_to_db(date = Date.yesterday)
      redis = RedisHelper.get_redis
      keys = RedisHelper.scan_for_stats_key "transfered_data:*:#{ date }", redis

      if keys.any?
        postings_amounts = redis.mget(keys)
        data_size_keys = keys.map {|key| key.gsub(/transfered_data/, 'transfered_bytes') }
        data_sizes = data_size_keys.any? ? redis.mget(data_size_keys) : []

        keys_amounts_sizes = keys.zip(postings_amounts, data_sizes)

        keys_amounts_sizes.each do |key,amount, data_size|
          fields = key.split(':')

          category_group = PostingConstants::CATEGORY_RELATIONS_REVERSE[fields[3]] rescue ""

          record = find_or_initialize_by(direction: fields[1], source: fields[2], category_group: category_group, category: fields[3], auth_token: fields[4], ip: fields[5], for_date: date)
          record.amount = record.amount.to_i + amount.to_i
          record.data_size = record.data_size.to_i + data_size.to_i
          record.save!
        end
        redis.del keys
        redis.del data_size_keys
      end
    end

    # return hash with keys - sources, values -- available groups for each source
    def get_available_groups
      Hash[ Posting::SOURCES_NAMES.keys.map { |source| [source, Posting::CATEGORY_GROUPS] } ]
    end

    def get_amount_for_groups_by_sources(for_date = Date.yesterday)
      counts = connection.select_all <<-SQL
        SELECT
            category_group, source,
            SUM(amount) AS in_daily_amount,
            SUM(data_size) AS in_data_size,
            (SUM(data_size) / SUM(amount)) AS in_avg_data_size,
            SUM(amount) AS out_daily_amount,
            (SUM(amount) * 30) AS in_monthly_amount,
            (SUM(amount) * 30) AS out_monthly_amount
        FROM
            statistic_by_transfered_data
        WHERE
            direction = 'in' AND for_date = '#{for_date}'
        GROUP BY category_group, source
        ORDER BY in_daily_amount DESC
      SQL

      by_groups = counts.to_a.group_by { |e| e['category_group'] }

      Hash[ by_groups.map { |group, v| [ group, Hash[ v.group_by { |e| e['source'] } ] ] } ]
    end

    def get_amount_for_categories_by_sources(category_group, for_date = Date.yesterday)
      counts = connection.select_all <<-SQL
        SELECT
            category, source,
            SUM(amount) AS in_daily_amount,
            SUM(data_size) AS in_data_size,
            (SUM(data_size) / SUM(amount)) AS in_avg_data_size,
            SUM(amount) AS out_daily_amount,
            (SUM(amount) * 30) AS in_monthly_amount,
            (SUM(amount) * 30) AS out_monthly_amount
        FROM
            statistic_by_transfered_data
        WHERE
            direction = 'in' AND for_date = '#{for_date}' AND category_group = '#{category_group}'
        GROUP BY category, source
        ORDER BY in_daily_amount DESC
      SQL

      by_groups = counts.to_a.group_by { |e| e['category'] }

      Hash[ by_groups.map { |group, v| [ group, Hash[ v.group_by { |e| e['source'] } ] ] } ]
    end

  end
end
