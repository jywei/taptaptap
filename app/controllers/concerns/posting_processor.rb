class PostingProcessor
  def initialize(client)
    @client = client
    @errors = {}
    @warnings = {}
  end

  def process(postings, remote_ip, auth_token) #TODO: refactor
    @error_responses = []
    @ids = {}
    timestamps = []
    __single_postings_times = []

    reads = 0
    source = postings.size > 0 ? postings[0][:source] : nil
    @redis = RedisHelper.hiredis

    postings.each do |posting_data|
      __single_posting_start_time = Time.now
      posting_data[:transit_ip_address] = remote_ip
      posting_data[:auth_token] = auth_token
      # data = posting_converter(posting_data)

      if posting_data[:status] == {'deleted' => 'true'} || posting_data[:deleted].to_s == 'true'
        @ids[posting_data[:external_id]] = handle_deleted_posting(posting_data)
        @error_responses << nil
        timestamps << posting_data[:timestamp]
        next
      end

      data = posting_converter(posting_data)
      timestamps << data[:timestamp]

      if data[:source] == 'HMNGS'
        SULO6.error "HMNGS DATA: #{posting_data.inspect}"
      end

      @current_error = nil
      @last_raw_posting = nil

      register_errors(data, RawPosting::CONVERTER_VALIDATION) # from converter

      if @errors.empty?
        posting = Remote::Posting.new(data, @client)

        if posting.save
          @ids[posting_data[:external_id]] = posting.id
        end

        @errors = posting.errors

        register_errors(data, RawPosting::MODEL_VALIDATION, posting.id)
      end

      @error_responses << @current_error

      __single_postings_times << ((Time.now - __single_posting_start_time) * 1000).round

      reset_errors
    end

    timestamp_values = timestamps.uniq.map { |t| "(#{t})" }.join(',')
    @client.query %Q(INSERT IGNORE timestamps VALUES #{timestamp_values};)

    response = {error_responses: @error_responses, wait_for: 0}
    response[:ids] = @ids unless @ids.empty?

    [response, __single_postings_times]
  end

  def add_error(attr, error)
    @errors[attr] ||= []
    @errors[attr] << error unless @errors.include?(error)
  end

  def add_warning(attr, message)
    @warnings[attr] ||= []
    @warnings[attr] << message unless @warnings.include?(message)
  end

  protected

  def posting_converter(data)
    # TODO: abstract method
  end

  def handle_deleted_posting(posting_data)
    source = "'#{ posting_data[:source] }'"
    external_id = "'#{posting_data[:external_id]}'"
    # status = "'deleted'"
    timestamp = "#{posting_data[:timestamp] || Time.now.to_i}"
    # timestamp_deleted = "#{posting_data[:timestamp_deleted] || Time.now.to_i}"
    time = Time.now.utc
    time_db = "'#{time.to_s(:db)}'"
    transit_ip_address = "'#{posting_data[:transit_ip_address]}'"
    external_url = "'#{posting_data[:external_url]}'"
    category = "'#{posting_data[:category]}'"

    RedisHelper.get_redis.incr "#{source}:deleted:#{time.to_i / 60 * 60}" # keys tied to minutely timestamps

    # TODO: FIX THIS STUFF
    Posting2.connection.query <<-SQL
        INSERT INTO postings#{ Posting2.current_volume }
          (`external_id`, `external_url`, `deleted`, `source`, `category`, `timestamp`, `transit_ip_address`, `created_at`, `updated_at`)
        VALUES
          (#{external_id}, #{external_url}, 1, #{source}, #{category}, #{timestamp}, #{transit_ip_address}, #{time_db}, #{time_db} )
    SQL

    id = Posting2.connection.query("SELECT LAST_INSERT_ID();").first.first[1]
    Posting2.connection.query "UPDATE current_volume SET volume = #{Posting2.current_volume + 1 }" if id % ::Posting::VOLUME_SIZE == 0

    id
  end

  def register_errors(posting, _module, posting_id = nil)
    unless @errors.empty?
      #@current_error = nil
      #else
      SULO6.error "posting processor"
      SULO6.error @errors
      SULO6.error _module

      PostingValidationInfo.insert_from_hash(@errors)

      @ids[posting[:external_id]] = nil

      e = @errors.first

      if @errors.is_a? ActiveModel::Errors
        @current_error.nil? ?
          @current_error = (e && e.last) :
          @current_error << '; ' <<  (e && e.last) # errors in AM are gathered in object
      else
        @current_error.nil? ?
          @current_error = (e && e.last) :
          @current_error << '; ' << (e && e.last.join(',')) # errors in processor are gathered in array
      end

      p "calling raw posting"
    end

    if not @warnings.empty? or not @errors.empty?
      if @last_raw_posting.present?
        #_errors = @last_raw_posting.error_messages + formatted_errors.join(';')
        #_warnings = @last_raw_posting.warning_messages + formatted_warnings.join(';')
        RawPosting.update_messages_for @last_raw_posting, formatted_errors, formatted_warnings
      else
        @last_raw_posting = RawPosting.insert_from_hash(posting, _module, formatted_errors, formatted_warnings, posting_id)
      end
    end
  end

  def formatted_errors
    (@errors.map { |k, v| "#{k}: #{v.is_a?(Array) ? v.join(';') : v}" })
  end

  def formatted_warnings
    (@warnings.map { |k, v| "#{k}: #{v.is_a?(Array) ? v.join(';') : v}" })
  end

  def reset_errors
    @errors = {}
  end
end
