class PostingsController < ApplicationController
  include ApplicationHelper
  use Rack::ContentLength

  skip_before_action :verify_authenticity_token

  #before_filter :check_format, only: [:create]
  #after_filter :add_available_postings_to_stats, only: :poll
  MAX_POLL_STATEMENTS = 3
  #include PostingApiUtils
  #before_filter :check_format, only: [:create]
  #before_filter :authorize_in_3taps, only: [:create, :anchor, :poll]
  SEARCH_API = ''
  WHITELIST = [] # for postings HTML access
  PROXY_IP_WHITELIST = []
  EXTERNAL_ID_BLACKLIST = [4919164309, 4919255020, 4919066135, 4919279802, 4919226980, 4915349926, 4918916949, 4919598243, 4919075534, 4919090053]

  after_filter :close_connection, only: [:create, :poll, :anchor]

  def show
    render json: {success: true, posting: Posting.find(params[:id])}
  rescue ActiveRecord::RecordNotFound
    render json: {success: false, error: "No posting with id=#{params[:id]}"}
  end

  def raw_create
    response = []
    for_geoapi = 0
    already_geolocated = 0
    if params[:format] == "CRAIG_HTML"
      params[:postings] = [params[:posting]] if params[:postings].blank?
      params[:postings].each do |posting|
        posting_body = posting[:body] || posting[:posting]
        data = DataConverters::Html::Craig.new(posting_body).parse
        data[:transit_ip_address] = request.remote_ip
        # data[:auth_token] = params[:auth_token]
        remote_posting = Remote::Posting.new(data) if data
        if remote_posting
          remote_posting.external_url = posting[:external_url]
          ids = {
              remote_posting.external_id => remote_posting.save ? remote_posting.id : nil
          }
          e = remote_posting.errors.messages.first
          response <<
              {
                  ids: ids,
                  wait_for: 0,
                  error_responses: [e && e.last.first]
              }
        end
        if data[:lat] && data[:long]
          for_geoapi += 1
        else
          already_geolocated +=1
        end
      end
    else
      response = {success: false}
    end
    #Statistics::Tracker.trace(Statistics::POSTING_RESPONDING) do
    #  Statistics::Tracker.add(Statistics::GEO_STATS, {num_postings: params[:postings].length,
    #                                                  num_already_geolocated: already_geolocated,
    #                                                  num_sent_to_geolocator: for_geoapi})
    #end

  ensure
    render json: response

  end

  def create
    __start_time = Time.now

    # RequestStorage.store_create_request(request)

    check_little_volume if Rails.env.production?

    filtered_posting_params = params

    response = {}
    __single_postings_times = []
    __filtering_time = nil
    __insert_time = nil

    if params[:postings]
      params.delete(:posting)
    end

    if params[:posting]
      params[:postings] = [params[:posting]]
    end

    if params[:postings].nil?
      response = {success: false, error: 'no posting param in request'}
      render json: response and return
    end

    if filtered_posting_params[:postings].first[:source] == 'CARS'
      filtered_posting_params[:postings].map do |posting|
        posting[:source] = 'CARSD'
        posting
      end
    end

    postings_by_category = {}

    filtered_posting_params[:postings].each do |posting|
      category = posting["category"]
      data_size = json_size(posting)

      if postings_by_category.has_key? category
        postings_by_category[category][:amount] += 1
        postings_by_category[category][:data_size] += data_size
      else
        postings_by_category[category] = {
            amount: 1,
            data_size: data_size
        }
      end
    end

    count = filtered_posting_params[:postings].size

    @client = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    @redis = RedisHelper.hiredis

    #filtered_posting_params[:postings].each do |posting|
    #  next if posting[:annotations].blank?

      # RedisHelper.get_redis.set("last_source_insert:#{ posting[:source] }", Time.now.to_i)

      # Posting.check_columns_widths(posting)
    #end

    #source = filtered_posting_params[:postings].first[:source]
    if (source = filtered_posting_params[:postings].first[:source]) == 'CRAIG'
      error_responses = []
      ids = {}
      timestamps = []

      @volume = Posting2.current_volume

      __filtering_time = Time.now

      without_timestamp_postings = {}

      filtered_posting_params[:postings].each_with_index do |posting_data, index|

        error_response = nil
        __single_posting_start_time = Time.now

        id = if posting_data[:status] == {'deleted' => 'true'} || posting_data[:deleted].to_s == 'true'
               SULO1.info "delete strategy"
               handle_deleted_posting(posting_data)
             else
               #SULO1.info "create strategy"
               validation_errors = {}

               a = []
               time = Time.now.utc.to_s(:db)

               a << "'#{posting_data[:account_id]}'"
               location = posting_data[:location] || {}

               annotations = posting_data[:annotations] ? posting_data[:annotations].to_hash : {}
               a << "'#{@client.escape(taps_serialize(annotations))}'"

               body = if posting_data[:body]
                        @client.escape(posting_data[:body])
                      else
                        '' # EBAYM has no body
                      end

               a << "'#{body}'"

               category = posting_data[:category]

               unless Posting::CATEGORIES.include?(category)
                 validation_errors['category'] = '0'
                 error_response = "#{category} category is invalid. Valid categories are #{Posting::CATEGORIES.join(', ')}."
               end

               category_group = Posting::CATEGORY_RELATIONS_REVERSE[posting_data[:category]]

               a << "'#{category}'"
               a << "'#{category_group}'"
               a << "'#{time}'"
               a << "'#{posting_data[:currency]}'"

               expires = if posting_data[:expires]
                           posting_data[:expires].to_i
                         else
                           0
                         end

               a << "'#{expires}'"
               a << "'#{posting_data[:external_id]}'"
               a << "'#{posting_data[:external_url]}'"
               a << "'#{@client.escape(posting_data[:heading].to_s)}'"
               a << "'#{posting_data[:html]}'"

               images = posting_data[:images] ? posting_data[:images] : []

               if images.first.is_a? String
                 validation_errors['images'] = '0'
                 images.map! { |image| {full: image} }
               end

               a << "'#{@client.escape(images.to_yaml)}'"
               a << "'#{posting_data[:language]}'"

               price = posting_data[:price]
               price = nil if price.to_i < 0
               price = price ? "'#{price}'" : 'NULL'

               a << price
               #SULO1.info "#{posting_data[:external_id]}: #{posting_data[:price].inspect} / #{price}"
               a << "'#{posting_data[:source]}'"

               status = Posting::CRAIG_STATUSES_BY_CAT[annotations['source_subcat'].to_s.split('|').last]
               status = 'for_sale' if status == '' || status.nil?

               a << "'#{status}'"

               without_timestamp = false

               posting_data[:timestamp] = if posting_data[:timestamp].present? # sometimes comes 'false'
                 posting_data[:timestamp].to_i
               else
                 SULO9.info "posting without timestamp external_id: #{posting_data[:external_id]}"
                 without_timestamp = true
                 Time.now.to_i
               end
               timestamp = posting_data[:timestamp]
               a << "'#{timestamp}'"
               timestamps << timestamp
               a << "'#{time}'"

               accuracy = nil || location[:accuracy]

               geolocation_status = Posting::GeoStatus::TO_LOCATE
               if location[:lat] && location[:long]
                 location_from_database = Posting2.connection.query("select location from craig_locations where `lat` = #{location[:lat]} and `long` = #{location[:long]}").to_a
                 if location_from_database and location_from_database.size > 0
                   location_from_database = YAML.load(location_from_database[0]["location"])
                   location_from_database.each { |k, v| location[k] = v }
                   geolocation_status = Posting::GeoStatus::LOCATED_CL_BY_SPREADSHEET

                   ZipsTracker.track(location[:zipcode], posting_data[:source], posting_data[:state], category_group, @redis) if location[:zipcode].present?
                   # StatisticByMetro.track(location[:metro], posting_data[:category]) if location[:metro].present?
                 end
               else
                 ZipsTracker.track_empty(@redis)
               end

               LiveLovely.track(annotations, posting_data[:price]) if category_group == "RRRR"

               a << "'#{location[:lat]}'"
               a << "'#{location[:long]}'"
               a << "'#{location[:country]}'"
               a << "'#{location[:state]}'"
               a << "'#{location[:metro]}'"
               a << "'#{location[:region]}'"
               a << "'#{location[:county]}'"
               a << "'#{location[:city]}'"
               a << "'#{location[:locality]}'"
               a << "'#{location[:zipcode]}'"
               a << "'#{@client.escape(location[:formatted_address].to_s)}'" #if location[:formatted_address]

               state = posting_data[:state]
               state = 'available' if state.nil? || state == ''
               a << "'#{state}'"

               a << "'#{posting_data[:flagged_status] || 0}'"
               a << "'#{posting_data[:origin_ip_address]}'"
               a << "'#{request.remote_ip}'" #posting_data['transit_ip_address']
               a << "'#{posting_data[:proxy_ip_address]}'"
               a << "'#{accuracy}'"

               a << "'#{geolocation_status}'"

               if error_response.nil?
                 _id = insert(%Q(`account_id`,`annotations`,
`body`, `category`, `category_group`,
`created_at`, `currency`, `expires`,
`external_id`, `external_url`, `heading`,
`html`, `images`, `language`, `price`,
`source`, `status`, `timestamp`, `updated_at`,
`lat`, `long`, `country`, `state`, `metro`, `region`, `county`, `city`, `locality`, `zipcode`, `formatted_address`,
`posting_state`, `flagged_status`, `origin_ip_address`, `transit_ip_address`, `proxy_ip_address`, `accuracy`, `geolocation_status`),
                              a.join(","),
                              posting_data[:external_id]
                 )

                 if validation_errors.has_value?('0')
                   @client.query %Q(
INSERT INTO posting_validation_infos (posting_id, created_at, updated_at, #{validation_errors.keys.join(',')})
VALUES (#{_id}, '#{time}', '#{time}', #{validation_errors.values.join(',')})
)

                   begin
                     insert(%Q(`account_id`,`annotations`,
`body`, `category`, `category_group`,
`created_at`, `currency`, `expires`,
`external_id`, `external_url`, `heading`,
`html`, `images`, `language`, `price`,
`source`, `status`, `timestamp`, `updated_at`,
`lat`, `long`, `country`, `state`, `metro`, `region`, `county`, `city`, `locality`, `zipcode`, `formatted_address`,
`posting_state`, `flagged_status`, `origin_ip_address`, `transit_ip_address`, `proxy_ip_address`, `accuracy`, `geolocation_status`, `text`),
                            (a + ["'#{posting_data.to_yaml}'"]).join(","),
                            nil, nil,
                            'raw_postings'
                     )
                   rescue Exception => e
                     SULO6.error e.message
                   end
                 end

                 without_timestamp_postings[_id] = posting_data[:external_url]

                 # redis_key = "#{posting_data[:source]}:#{posting_data[:category]}:#{posting_data[:external_id]}"
                 #
                 # if RedisHelper.get_redis.sismember("updated_postings:origins:#{ Date.today }", redis_key) or RedisHelper.get_redis.sismember("updated_postings:origins:#{ Date.today - 1.day }", redis_key)
                 #   RedisHelper.get_redis.incr("updates:#{posting_data[:source]}:#{posting_data[:category]}:#{ Date.today }")
                 #
                 #   if _id.present?
                 #    Posting2.connection.query "UPDATE postings#{ Posting2.current_volume } SET is_update = TRUE WHERE id = #{ _id }"
                 #   end
                 # else
                 #   RedisHelper.get_redis.sadd "updated_postings:origins:#{ Date.today }", redis_key
                 # end

                 _id
               else
                 q = %Q(
INSERT INTO posting_validation_infos (posting_id, created_at, updated_at, #{validation_errors.keys.join(',')}, original_external_id, original_source, auth_token, ip_address)
VALUES (NULL, '#{time}', '#{time}', #{validation_errors.values.join(',')}, #{posting_data[:external_id] || 'NULL'}, '#{posting_data[:source]}', '#{params[:auth_token]}', '#{request.remote_ip}')
)
                 @client.query q

                 begin
                   SULO6.info error_response

                   insert(%Q(`account_id`,`annotations`,
`body`, `category`, `category_group`,
`created_at`, `currency`, `expires`,
`external_id`, `external_url`, `heading`,
`html`, `images`, `language`, `price`,
`source`, `status`, `timestamp`, `updated_at`,
`lat`, `long`, `country`, `state`, `metro`, `region`, `county`, `city`, `locality`, `zipcode`, `formatted_address`,
`posting_state`, `flagged_status`, `origin_ip_address`, `transit_ip_address`, `proxy_ip_address`, `accuracy`, `geolocation_status`, `text`),
                          (a + ["'#{posting_data.to_yaml}'"]).join(","),
                          nil, nil,
                          'raw_postings'
                   )
                 rescue Exception => e
                   SULO6.error e.message
                 end

                 nil
               end
             end

        # RedisHelper.get_redis.lpush(Annotation::QUEUE_NAME, id) if id.present? and Annotation::PROCESSING_ENABLED

        ids[posting_data[:external_id]] = id
        error_responses[index] = error_response
        __single_postings_times << ((Time.now - __single_posting_start_time) * 1000).round
      end

      time = Time.now.utc
      date_now = time.strftime("%Y-%m-%d")
      _timestamp = Time.now.to_i

      reads = 3

      @redis.write ["incrby", "stats:#{date_now}:#{time.strftime("%H")}:#{request.remote_ip}", filtered_posting_params[:postings].size]
      # @redis.write ["incrby", "stats:#{date_now}:#{_timestamp}:#{request.remote_ip}", filtered_posting_params[:postings].size]
      @redis.write ["incrby", "stats:#{date_now}:#{Time.at(_timestamp).strftime("%Y-%m-%d")}:#{request.remote_ip}", filtered_posting_params[:postings].size]
      @redis.write ["incrby", "stats:CRAIG:added:#{time.to_i / 60 * 60}", filtered_posting_params[:postings].size]  # keys tied to minutely timestamps

      time = Time.now

      if without_timestamp_postings.size > 0
        @redis.write ["incrby", "stats:#{Time.now.strftime("%Y-%m-%d")}:empty_timestamp:CRAIG", without_timestamp_postings.size]

        without_timestamp_postings.each { |key, value| @redis.write ["hset", "stats:#{Time.now.strftime("%Y-%m-%d")}:empty_timestamp_ids:CRAIG", key, value] }

        reads += 1 + without_timestamp_postings.size
      end

      @redis.write ["incrby", "stats:total:added:day:#{ time.strftime('%d.%m.%Y') }", filtered_posting_params[:postings].size]
      @redis.write ["incrby", "stats:total:added:hour:#{ time.strftime('%d.%m.%Y:%H') }", filtered_posting_params[:postings].size]
      @redis.write ["incrby", "stats:total:added:minute:#{ time.strftime('%d.%m.%Y:%H:%M') }", filtered_posting_params[:postings].size]
      @redis.write ["incrby", "stats:total:added:second:#{ time.strftime('%d.%m.%Y:%H:%M:%S') }", filtered_posting_params[:postings].size]

      reads += 4

      reads.times { @redis.read }

      # !!!UNCOMMENT TO USE SEPARATE CRAIG PROCESSOR
      #p = CraigPostingProcessor.new @client
      #Statistics::Tracker.trace(Statistics::POSTING_RESPONDING) do
      #  response, __single_postings_times = p.process(filtered_posting_params[:postings], request.remote_ip)
      #end
      # !!!END UNCOMMENT

      __insert_time = Time.now

      unless timestamps.empty?
        timestamp_values = timestamps.uniq.map { |t| "(#{t})" }.join(',')
        @client.query %Q(INSERT IGNORE timestamps VALUES #{timestamp_values};)
      end

      response = {error_responses: error_responses, wait_for: 0}
      unless ids.empty?
        response[:ids] = ids

        begin
          id = ids.values[rand(ids.count)]
          q = %Q(INSERT INTO posting_stats (posting_id, created_at) VALUES (#{id}, '#{Time.now.to_s(:db)}'))
          @client.query q
        rescue Exception => e
          SULO3.error e.message
          SULO3.error e.backtrace.join("\n")
        end

      end
    else
      # if source == 'HMNGS'
      #   filtered_posting_params[:postings].uniq! { |posting| posting[:external_id] }
      #
      #   external_ids = filtered_posting_params[:postings].map { |posting| posting[:external_id] }
      #
      #   filtered_posting_params[:postings].reject! do |posting|
      #     next if posting[:external_id].blank?
      #
      #     res = @client.query("SELECT 1 AS present FROM postings#{ Posting2.current_volume } WHERE external_id = '#{ posting[:external_id] }' AND source = 'HMNGS'").to_a
      #
      #     (res.size > 0 && res.first['present'] == 1)
      #   end
      #
      #   if filtered_posting_params[:postings].blank?
      #     postings_response = Hash[external_ids.zip([nil] * external_ids.size)]
      #     anchor = RecentAnchor.anchor
      #
      #     response = {success: true, anchor: anchor, postings: postings_response}
      #     render json: response and return
      #   end
      # end

      unless PostingConstants::SOURCES.include? source
        SULO1.info "Unknown source '#{ source }' came from #{ request.remote_ip }"
        response = { success: false, error: "Invalid source '#{ source }'" }
        render json: response and return
      end

      #if source == 'HMNGS'
      # File.open("log/hmngs#{Time.now.to_s}.log", 'w'){|f| f.write(params.to_s)}
      # NotificationMailer.create_notice('HMNGS added', 'HMNGS added', ['marat@3taps.com', 'b.savchuk@svitla.com']).deliver!
      #end
      __filtering_time = Time.now
      processor_instance = nil

      begin
        processor_instance = "#{source.downcase.camelize}PostingProcessor".constantize.new @client
        #Statistics::Tracker.trace(Statistics::POSTING_RESPONDING) do
          #end
      rescue NameError => e
        SULO1.info e.message
        SULO1.error e.backtrace.join("\n")

        filename = "#{Rails.root}/lib/data/#{source}_parsing_configuration.csv"
        processor_class = File.exists?(filename) ? CSVPostingProcessor : DefaultPostingProcessor
        processor_instance = processor_class.new @client
        #Statistics::Tracker.trace(Statistics::POSTING_RESPONDING) do
        #end
      end

      # TODO: check if processor_instance is nil and do something with that
      response, __single_postings_times = processor_instance.process(filtered_posting_params[:postings], request.remote_ip, params[:auth_token])

      __insert_time = Time.now

      SULO1.info '---------------------------'
      SULO1.info source
      SULO1.info response
    end

    postings_by_category.each do |category, data|
      StatisticByTransferedData.track({ direction: :in, ip: request.remote_ip, auth_token: params[:auth_token], source: filtered_posting_params[:postings].first[:source], category: category, amount: data[:amount], redis_connection: @redis, data_size: data[:data_size] })
    end

    # TransferedDataWorker.perform_async(filtered_posting_params[:postings], request.remote_ip, params[:auth_token])

    render json: response
    __render_time = Time.now

    begin
      count = response[:error_responses].size
      time = (Time.now - __start_time) * 1000
      #SULO5.info "#{source} #{time_per_posting.round}ms for 1 posting; #{count} postings process time: #{time.round}ms"

      filter_time = (__filtering_time - __start_time) * 1000
      insert_time = (__insert_time - __filtering_time) * 1000
      time_per_posting = insert_time / count
      render_time = (__render_time - __insert_time) * 1000
      min_posting_time = __single_postings_times.min
      max_posting_time = __single_postings_times.max
      overhead = (Time.now - __render_time) * 1000
      #SULO5.info "#{source} filter: #{filter_time.round} ms; insert: #{insert_time.round}ms; render: #{render_time.round}ms; overhead: #{overhead.round}ms"
      #SULO5.info "postings: #{__single_postings_times.join('ms, ')}"

      __pinsert_start = Time.now
      profiler_token = params[:auth_token] || (request.remote_ip == '108.175.163.170' ? 'Brian server' : 'CRAIG partner server')
      q = %Q(INSERT INTO insert_profilers
(source, filter, `insert`, render, overhead, min_posting_time, average_per_posting, max_posting_time, postings_count, total_time, postings, created_at, updated_at, auth_token)
VALUES ('#{source}',
'#{filter_time.round}',
'#{insert_time.round}',
'#{render_time.round}',
'#{overhead.round}',
'#{min_posting_time.round}',
'#{time_per_posting.round}',
'#{max_posting_time.round}',
'#{count}',
'#{time.round}',
'#{__single_postings_times.join('ms, ')}', '#{Time.now.utc.to_s(:db)}', '#{Time.now.utc.to_s(:db)}', '#{profiler_token}')
)
      @client.query q
      SULO5.info "insert profiler: #{((Time.now - __pinsert_start) * 1000).round}ms"
    rescue Exception => e
      SULO5.error e.message
      SULO5.error e.backtrace.join("\n")
    end
  end

  def anchor
    cors_set_access_control_headers

    redis = RedisHelper.hiredis
    redis.write [ 'hincrby', "stats:usage:#{params[:auth_token]}", 'anchor', 1 ]
    redis.read

    error = validate_anchor_params(anchor_params)
    render json: {success: false, error: error} and return if error.present?

    @client = Posting2.connection
    @conditions = anchor_params

    escaped_timestamp = @client.escape(@conditions[:timestamp])
    @timestamp = @client.query("SELECT timestamp FROM `timestamps`  WHERE (timestamp <= #{escaped_timestamp}) ORDER BY timestamp DESC LIMIT 1").to_a
    render json: {success: false, error: 'No anchor found'} and return if @timestamp.empty?
    @timestamp = @timestamp[0]['timestamp']
    @current_volume = Posting2.current_volume
    @volume = nil
    anchor = try_database_for_anchor
    render json: {success: false, error: 'No anchor found'} and return unless anchor

    anchor = [anchor, RecentAnchor.anchor].min
    render json: {success: true, anchor: anchor}
  end

  def anchor2
    cors_set_access_control_headers

    redis = RedisHelper.hiredis
    redis.write [ 'hincrby', "stats:usage:#{params[:auth_token]}", 'anchor', 1 ]
    redis.read

    error = validate_anchor_params(anchor_params)
    render json: {success: false, error: error} and return if error.present?

    @client = Posting2.connection
    @conditions = anchor_params

    timestamp = @conditions[:timestamp].to_i

    anchor = PostingThreshold.get_id_by_timestamp(timestamp)

    render json: {success: false, error: 'No anchor found'} and return unless anchor

    anchor = [anchor, RecentAnchor.anchor].min
    render json: {success: true, anchor: anchor}
  end

  def poll
    begin
      mysql_processes = []

      mysql_processes << Posting2.connection.query("show full processlist;")

      Timeout::timeout(59) do
        postings = nil

        begin
          error = validate_poll_params(params.except(:action, :controller))
          render json: {success: false, error: error} and return if error.present?

          @client = Posting2.connection
          @conditions = params.except(:auth_token, :action, :controller)
          @auth_token = params[:auth_token]

          postings = if params[:anchor].nil?
                       []
                     else
                       generate_poll_conditions

                       if @statement_values.size > MAX_POLL_STATEMENTS or @statements.count(' OR ') > 0
                         perform_polling2
                       else
                         perform_polling
                       end
                     end

        rescue Exception => exception
          SULOEXC.error("#{Time.now.strftime("%Y_%m_%d_%H_%M_%S_%6N")}|:|#{exception.message}|:|#{exception.backtrace.join(", ")}|)")
          SULOEXC.info params.to_s

          message = exception.inspect
          message = message[2..message.index(' for #<')-1] if message.index(' for #<')
          TapsException.track(message: message, notify: true, details: params.to_s, module_name: 'polling API')

          postings = []
        end

        begin
          if @auth_token == SEARCH_API && postings.size > 0
            SULO3.error "poll postings: #{postings.size}"
            if !(ps = PostingStat.not_polled.where("posting_id IN (#{postings.collect { |p| p['id'] }.join(',')})")).blank?
              ps.update_all("polled_at = '#{Time.now.to_s(:db)}'")
            end
          end

          mysql_processes << Posting2.connection.query("show full processlist;")
        rescue Exception => e
          SULO3.error "poll error:"
          SULO3.error e.message
          SULO3.error e.backtrace.join("\n")
        end

        @redis = RedisHelper.hiredis

        TransferedDataWorker.perform_async postings, request.remote_ip, @auth_token

        json_postings = convert_to_response_form(postings, poll_params[:retvals].include?('annotations'), poll_params[:retvals].include?('id'))
        ResponseCount.create request_ip: request.remote_ip, count: postings.size
        json_ready_data = json_postings.to_json

        data_size = json_ready_data.bytesize

        @redis.write ['hincrby', "stats:usage:#{params[:auth_token]}", 'polling_api', 1]
        @redis.write ['hincrby', "stats:usage:#{params[:auth_token]}", 'received_data', data_size]
        @redis.write ['hincrby', "stats:usage:#{params[:auth_token]}", 'number_of_postings', postings.size]
        @redis.write ['hincrby', "stats:usage:#{params[:auth_token]}", 'polling_api_data_size', data_size]
        4.times { @redis.read }

        cors_set_access_control_headers

        ActiveSupport::JSON::Encoding.escape_html_entities_in_json = false
        render json: json_ready_data
      end
    rescue Timeout::Error => e
      mysql_processes << Posting2.connection.query("show full processlist;")

      mysql_processes.map! do |pack|
        pack.to_a.select { |row| row['State'].present? and row['State'] != 'Waiting for table level lock' }
      end

      NotificationMailer.error_504_with_mysql_stats(e, params, mysql_processes).deliver!
      raise
    rescue
      raise
    end
  end

  private

  def json_size(value, depth = 0)
    size = 0

    if value.is_a? NilClass
      size += 5 # null,
    elsif value.is_a? Array
      size += 2 + value.map { |elt| json_size(elt, depth + 1) + 1 }.sum # [values]

      size -= 1 if value.size > 1  # trim last comma
    elsif value.is_a? Hash
      size += value.map { |k, v| k.to_s.bytesize + json_size(v, depth + 1) + 3 }.sum # {"key":value}

      size -= 1 if value.keys.size > 1 # trim last comma
    elsif value.is_a? String
      size += 3 + value.bytesize # "string",
    elsif value.is_a? Float
      size += 3 + value.to_s.bytesize # "string", "-3.14",
    else # if value.is_a? TrueClass or value.is_a? FalseClass or value.is_a? NilClass or value.is_a? Numeric
      size += 1 + value.to_s.bytesize # value,
    end

    size
  end

  def handle_deleted_posting(posting_data)
    source = "'#{posting_data[:source]}'"
    external_id = "'#{posting_data[:external_id]}'"
    status = "'deleted'"
    timestamp = "#{posting_data[:timestamp] || Time.now.to_i}"
    timestamp_deleted = "#{posting_data[:timestamp_deleted] || Time.now.to_i}"
    time = Time.now.utc
    time_db = "'#{time.to_s(:db)}'"
    transit_ip_address = "'#{request.remote_ip}'"
    external_url = "'#{posting_data[:external_url]}'"
    category = "'#{posting_data[:category]}'"

    RedisHelper.get_redis.incr "#{source}:deleted:#{time.to_i / 60 * 60}" # keys tied to minutely timestamps

    insert(
        %Q(`external_id`, `external_url`, `deleted`, `source`, `category`, `timestamp`, `transit_ip_address`, `created_at`, `updated_at`),
        %Q(#{external_id}, #{external_url}, 1, #{source}, #{category}, #{timestamp}, #{transit_ip_address}, #{time_db}, #{time_db}),
        posting_data[:external_id],
        1 #deleted
    )
  end

  def insert(fields, values, external_id, deleted = 0, table = "postings#{@volume}")
    @client.query %Q(
INSERT INTO #{table} (#{fields})
VALUES (#{values});
)

    if table =~ /postings/
      # DON'T TOUCH!!!
      # getting last inserted id from postings table
      r = @client.query("SELECT LAST_INSERT_ID();")
      #id = r.first[0] # for AR::Base.connection result
      id = r.first.first[1] # for mysql result

      # insert into external id table
      #@client.query %Q(
#INSERT INTO `external_id_volumes` (`external_id`, `source`, `volume`, `deleted`, `created_at`, `updated_at`)
#VALUES ('#{external_id}', 'CRAIG', #{@volume}, #{deleted}, '#{Time.now.utc.to_s(:db)}', '#{Time.now.utc.to_s(:db)}' )
#)

      # checking id against VOLUME_SIZE
      if (id % Posting::VOLUME_SIZE == 0)
        @volume += 1
        @client.query "UPDATE current_volume SET volume = #{@volume}"
      end

      id
      # END OF DON'T TOUCH!!!
    end
  rescue Exception => e
    SULO2.info fields
    SULO2.info values
    raise e
  end

  def generate_poll_conditions
    local_conditions = @conditions.clone

    posting_id = local_conditions.delete(:anchor)
    updates_only = local_conditions.delete(:new_only)
    statements = ["id > #{posting_id}"]
    volume = Posting2.volume_by_id(posting_id)
    volume = nil if volume < FirstVolume.first_volume

    if fields = local_conditions.delete(:retvals)
      select_fields = fields.is_a?(String) ? fields.split(',') : fields
      select_fields.map!{|f| f.strip}
      select_fields.delete('html') unless WHITELIST.include?(@auth_token)
      select_fields << 'posting_state' if select_fields.delete('state')

      (select_fields << Location::LEVELS << 'lat' << '`long`' << 'accuracy' << 'formatted_address' << 'geolocation_status').flatten if select_fields.delete 'location'
      select_fields << 'id' unless select_fields.include?('id')
    else
      select_fields = %w(id source category country state metro region county city locality zipcode external_id external_url heading timestamp annotations lat `long` accuracy formatted_address geolocation_status deleted)

      select_fields += %w(origin_ip_address transit_ip_address) if @auth_token == SEARCH_API
    end

    unless select_fields.include? 'category_group'
      @exclude_category_group = true
      select_fields << 'category_group'
    end

    if local_conditions.has_key?('category') and local_conditions.has_key?('category_group')
      # raise "" unless PostingConstants::CATEGORY_RELATIONS[local_conditions['category']] == local_conditions['category_group']
      local_conditions.delete 'category_group'
    end

    # indexes_columns = ActiveRecord::Base.connection.indexes("postings#{ Posting2.current_volume }")
    #
    # using_index = indexes_columns.group_by { |i| (i.columns & local_conditions.keys).size }
    #
    # using_index = using_index[local_conditions.size]
    #
    # local_conditions = Hash[local_conditions.sort_by do |k, _|
    #   using_index.columns.index(k)
    # end]

    select_fields = select_fields.join(',')

    rpp = local_conditions.delete(:rpp).try(:to_i)
    max = max_number_of_postings(select_fields).to_i
    rpp = max if rpp.nil? || rpp > max

    statement_values = []
    local_conditions.each do |attr_name, value|
      if attr_name.match /^location\.(.*)/
        logical_data = handle_with_logical_operators($1, value)
        statements << logical_data[:all_statements]
        statement_values << logical_data[:statement_values]
      elsif %w(state source category_group category status).include? attr_name
        attr_name = 'posting_state' if attr_name == 'state'
        logical_data = handle_with_logical_operators(attr_name, value)
        statements << logical_data[:all_statements]
        statement_values << logical_data[:statement_values]
      else
        statements << "`#{attr_name}` = ?"
        statement_values << value
      end
    end

    if updates_only == '1'
      statements << '`is_update` = TRUE'
      SULO8.info "User with auth_token `#{ @auth_token }` uses `new_only` key"
    end

    right_border_for_id = RecentAnchor.anchor
    @last_volume_id_bound = "id < #{right_border_for_id}"

    @statement_values = statement_values.flatten
    @select_fields = select_fields
    @statements = statements
    @rpp = rpp
    @needed_amount = rpp
    @volume = volume
    @last_volume = Posting2.current_volume
    @very_last_volume = LastVolume.last_volume
    @anchor = posting_id
    @postings = []
    @anchors_volume = Posting2.volume_by_id(right_border_for_id)
  end

  def perform_polling
    @statements << @last_volume_id_bound if @volume == @anchors_volume
    #sql = "SELECT #{@select_fields} FROM postings#{@volume} WHERE #{@statements.join(" AND ")} ORDER BY id ASC LIMIT #{@rpp}"
    Posting.table_name = "postings#{@volume}"
    sql = if @auth_token == SEARCH_API
        Posting.select(@select_fields).where(@statements.join(" AND "), *@statement_values).limit(@rpp).to_sql
      else
        Posting.select(@select_fields).where(@statements.join(" AND "), *@statement_values).order('id ASC').limit(@rpp).to_sql
      end

    IndexTrackingWorker.perform_async(sql)

    temp_postings = @client.query(sql).to_a
    temp_postings.map! do |posting|
      begin
        posting['annotations'] = Oj.load(posting['annotations']) if posting['annotations'].present?
        posting['images'] = YAML.load(posting['images']) if posting['images'].present?
        posting['body'] = posting['body'] if posting['body'].present?
        posting['heading'] = posting['heading'] if posting['heading'].present?
        posting['flagged_status'] = posting.delete('flagged') if @select_fields['flagged']
        if posting['deleted'].present?
          posting['deleted'] = posting['deleted'] == 1
        end
        posting
      rescue Exception => e
        SULOEXC.error "----------------------YAML PARSING ERROR #{posting['id']}"
        SULOEXC.error "----------------------#{e.message}"
        nil
      end
    end.compact!
    @postings.concat temp_postings

    if @postings.size < @needed_amount && @volume.to_i < @anchors_volume && @volume < @very_last_volume
      @volume = @volume.nil? ? FirstVolume.first_volume : @volume + 1
      @rpp = @needed_amount - @postings.size
      @statements.reject! { |s| s =~ /^id (>|<)/ }
      perform_polling
    end

    @postings
  end

  def perform_polling2
    Posting.table_name = "postings#{@volume}"
    ids_query = Posting.select(:id).where(@statements.join(' AND '), *@statement_values).order('id ASC').limit(@rpp).to_sql
    IndexTrackingWorker.perform_async(ids_query)

    ids_condition = @client.query(ids_query).to_a.map { |e| e['id'].to_i }

    temp_postings = @client.query(Posting.select(@select_fields).where(id: ids_condition).to_sql).to_a
    temp_postings.map! do |posting|
      begin
        posting['annotations'] = Oj.load(posting['annotations']) if posting['annotations'].present?
        posting['images'] = YAML.load(posting['images']) if posting['images'].present?
        posting['body'] = posting['body'] if posting['body'].present?
        posting['heading'] = posting['heading'] if posting['heading'].present?
        posting['flagged_status'] = posting.delete('flagged') if @select_fields['flagged']
        if posting['deleted'].present?
          posting['deleted'] = posting['deleted'] == 1
        end
        posting
      rescue Exception => e
        SULOEXC.error "----------------------YAML PARSING ERROR #{posting['id']}"
        SULOEXC.error "----------------------#{e.message}"
        nil
      end
    end.compact!
    @postings.concat temp_postings

    if @postings.size < @needed_amount && @volume.to_i < @anchors_volume && @volume < @very_last_volume
      @volume = @volume.nil? ? FirstVolume.first_volume : @volume + 1
      @rpp = @needed_amount - @postings.size
      @statements.reject! { |s| s =~ /^id (>|<)/ }
      perform_polling2
    end

    @postings
  end

  def max_number_of_postings fields
    if fields.include?('body') && fields.include?('html')
      1_000
    elsif fields == 'id'
      10_000
    else
      1_000
    end
  end

  def try_database_for_anchor
    id = @client.query("SELECT id FROM `postings#{@volume}` WHERE (timestamp = #{@timestamp}) LIMIT 1").to_a[0].try(:[], 'id')
    if id.nil?
      @volume += 1 if @volume.present?
      @volume ||= FirstVolume.first_volume
      id = try_database_for_anchor if @volume <= @current_volume
    end
    id
  end

  def posting_params
    if params[:posting]
      params[:postings] = [ params[:posting] ]
      params.delete(:posting)
    end

    bounds_mask = [:min_lat, :max_lat, :min_long, :max_long]
    location_mask = [:lat, :long, :accuracy, {:bounds => bounds_mask}, :country, :state, :metro, :region, :county, :city, :locality, :zipcode, :formatted_address]
    images_mask = [:full, :full_width, :full_height, :thumbnail, :thumbnail_width, :thumbnail_height]
    posting_mask = [:source, :category, {:location => location_mask}, :external_id, :external_url, :heading, :body, :html, :timestamp, :expires, :language, :price, :currency, :annotations, :status, :flagged, :deleted, :immortal, {:images => images_mask}]
    params.delete :postings if params[:posting].present?
    filtered_params = params.permit(:auth_token, {:posting => posting_mask}, {:postings => posting_mask})
    filtered_params[:postings] = [filtered_params[:postings]] if filtered_params[:postings] && !filtered_params[:postings].is_a?(Array)
    filtered_params
  end

  def anchor_params
    params.permit(:auth_token, :timestamp)
  end

  def poll_params
    filtered_params = params.permit(:auth_token, :anchor, :source, :category_group, :category, :country, :state, :metro, :region, :county, :city, :locality, :zipcode, :status, :retvals, :new_only)
    filtered_params[:retvals] = Posting::DEFAULT_RETVALS and return filtered_params if filtered_params[:retvals].blank?
    filtered_params[:retvals] = filtered_params[:retvals].split(',') & Posting::ALLOWED_RETVALS
    filtered_params[:retvals] = Posting::DEFAULT_RETVALS if filtered_params[:retvals].blank?
    filtered_params
  end

  def check_format
    raise ActionController::RoutingError.new('Not Found') if request.content_type != 'application/json'
  end

  #def add_available_postings_to_stats
  #  available = Posting.last.id - @postings.last.id
  #  Statistics::Tracker.add(Statistics::AVAILABLE_POSTINGS, available)
  #end

  def close_connection
    @client.close if @client
  end

  def validate_retvals(retvals)
    if retvals.is_a? String
      retvals = retvals.split(',')
    end

    Posting.table_name = "postings#{Posting2.current_volume}"
    tmp_posting = Posting.new
    errors = []

    retvals.each do |field|
      errors << "`#{field}` field does not exist (retvals)" unless tmp_posting.respond_to? field
    end

    if retvals.include?('proxy_ip_address') && !PROXY_IP_WHITELIST.include?(params['auth_token'])
      errors << "you have not permission get proxy_ip_address"
    end

    errors
  end

  def validate_poll_params(poll_params)
    errors = []

    errors << 'auth_token is required' if poll_params[:auth_token].blank?

    keys = poll_params.keys

    permitted_keys = [:auth_token, :anchor, :source, :category_group, :category, :'location.country', :'location.state',
      :'location.metro', :'location.region', :'location.county', :'location.city', :'location.locality',
      :'location.zipcode', :status, :state, :retvals, :rpp, :new_only, :proxy_ip_address]
    permitted_keys.map!{|k| k.to_s}

    other_keys = keys - permitted_keys

    unless other_keys.empty?
      errors << "#{other_keys.join(', ')} params not supported in polling"
    end

    if keys.include?('proxy_ip_address') && !PROXY_IP_WHITELIST.include?(params['auth_token'])
      errors << "you have not permission get proxy_ip_address"
    end

    #if (keys.include?('long') || keys.include?('lat'))
    #  errors << 'polling by lat and long not supported'
    #end

    if poll_params[:retvals]
      errors += validate_retvals(poll_params[:retvals])
    end

    if poll_params[:anchor]
      if poll_params[:anchor].to_i != 0
        r = Posting2.posting_exists_by_id?(poll_params[:anchor])
        errors << "anchor is invalid: #{r.inspect}" unless Posting2.posting_exists_by_id?(poll_params[:anchor])
      else
        errors << 'anchor format is invalid'
      end
      #end
    end

    parsed_logical_fields_for_validation(poll_params[:source]).each do |source|
      errors << "source is invalid (available sources are #{Posting::SOURCES.join(', ')})" unless Posting::SOURCES.include?(source)
    end

    parsed_logical_fields_for_validation(poll_params[:category_group]).each do |category_group|
      errors << "category_group is invalid (available category_groups are #{Posting::CATEGORY_GROUPS.join(', ')})" unless Posting::CATEGORY_GROUPS.include?(category_group)
    end

    parsed_logical_fields_for_validation(poll_params[:category]).each do |cat|
      errors << "category is invalid (available categories are #{Posting::CATEGORIES.join(', ')})" unless Posting::CATEGORIES.include?(cat)
    end

    parsed_logical_fields_for_validation(poll_params[:status]).each do |status|
      errors << "status is invalid (available statuses are #{Posting::STATUSES.join(', ')})" unless Posting::STATUSES.include?(status)
    end

    parsed_logical_fields_for_validation(poll_params[:state]).each do |state|
      errors << "state is invalid (available state are #{Posting::STATES.join(', ')})" unless Posting::STATES.include?(state)
    end

    errors.join(', ')
  end

  def validate_anchor_params(anchor_params)
    errors = []
    errors << 'auth_token is required' if anchor_params[:auth_token].blank?
    errors << 'timestamp is required' if anchor_params[:timestamp].blank?
    timestamp = Integer(anchor_params[:timestamp]) rescue nil
    errors << 'timestamp must be a number' if anchor_params[:timestamp] and not timestamp
    errors.join(', ')
  end

  def convert_to_response_form(postings, annotations_included, id_included)
    anchor = postings.present? ? [postings.last['id'], RecentAnchor.anchor].min : Posting2.default_anchor

    if postings.present? && (postings.last['id'] > RecentAnchor.anchor)
      SULO7.error "-----------------------------"
      SULO7.error "cur anchor: #{RecentAnchor.anchor}"
      SULO7.error "postings last id: #{postings.last['id']}"
      SULO7.error "returned value: #{anchor}"
      SULO7.error "last id > anchor!!!"
    end
    postings_json = postings.map do |posting|
      if posting.is_a? TrueClass
        SULOEXC.error('true class in postings')
        nil
      else
        json_posting = posting.except(*Location::LEVELS)
        location_hash = Posting.location_as_hash(posting)
        json_posting['location'] = location_hash if location_hash.present?
        json_posting['state'] = json_posting.delete('posting_state') if json_posting.has_key?('posting_state')
        json_posting.delete('formatted_address')
        json_posting.delete('geolocation_status')
        json_posting.delete('id') unless id_included
        json_posting.delete('lat')
        json_posting.delete('long')
        json_posting.delete('accuracy')
        json_posting.delete('category_group') if @exclude_category_group
        json_posting
      end
    end.compact
    {success: true, anchor: anchor, postings: postings_json}
  end

  def handle_with_logical_operators(field, value)
    all_items = value.split('|')
    statement_values = []
    positive_statements = []
    positive_values = []
    negative_statements = []
    negative_values = []
    all_items.each do |item|
      if item[0] == '~'
        negative_statements << "#{field} <> ?"
        negative_values << item[1..-1]
      else
        positive_statements << "#{field} = ?"
        positive_values << item
      end
    end
    positive_string = positive_statements.present? ? "(#{positive_statements.join(' OR ')})" : nil
    negative_string = negative_statements.present? ? "(#{negative_statements.join(' AND ')})" : nil
    all_statements = [positive_string, negative_string].compact.join(' AND ')
    statement_values = positive_values + negative_values
    result = {all_statements: "(#{all_statements})", statement_values: statement_values}
    SULO7.info "<OR statements> #{result.inspect}" if positive_statements.present? and positive_statements.size > 1
    result
  end

  def parsed_logical_fields_for_validation(field)
    return [] if field.blank?
    field.split('|').map do |cat|
      cat[0] == '~' ? cat[1..-1] : cat
    end
  end

  def check_little_volume
    redis = RedisHelper.existing_redis

    if (LastVolume.last_volume - Posting2.current_volume) <= 5
      redis.set("little_volume", 1)
      sent = redis.get("little_volume_notification_sent").to_i
      if sent != 1
        subject = "Let little volume"
        message = "Difference between last_volume and current_volume <=5"
        NotificationMailer.notice(message, subject).deliver!
        SystemEvent.create event: "little volume", description: "difference between last_volume and current_volume <=5"
        redis.set("little_volume_notification_sent", 1)
      end
    else
      redis.set("little_volume", 0)
      redis.set("little_volume_notification_sent",0)
    end
  end
end
