module Remote
  class Posting
    include ::PostingConstants
    include ::PostingGeoStatuses

    #TODO: Model shouldn't modify incoming data
    include ActiveModel::Validations

    DEFAULT_STATUS = 'for_sale'
    DEFAULT_STATE = 'available'

    validates_inclusion_of :category, in: ::Posting::CATEGORIES, message: "%{value} category is invalid. Valid categories are #{::Posting::CATEGORIES.join(', ')}."
    validates_inclusion_of :source, in: ::Posting::SOURCES, message: "%{value} source is invalid"
    validates_inclusion_of :status, in: ::Posting::STATUSES, message: "%{value} status is invalid"
    validates_inclusion_of :state, in: ::Posting::STATES, message: "%{value} state is invalid"
    validates_inclusion_of :flagged_status, in: ::Posting::FLAGGED_STATUSES.map{|el| el[:value]}, message: "%{value} flagged_status is invalid"

    def initialize(posting_data, client = ::Posting2.connection)
      @data = posting_data
      @client = client
      @auth_token = @data.delete :auth_token

      fill_australian_locations if AUSTRALIAN_SOURCES.include?(@data[:source])
    end

    def save
      result = nil
      #Statistics::Tracker.trace(Statistics::POSTING_VALIDATION) do
        result = valid?
      #end
      if result
        #Statistics::Tracker.trace(Statistics::POSTING_INSERT) do
          save_posting
          after_save
        #end
      #else
      #  save_errors #moved to processor
      end
      result
    end

    def external_url=(value)
      @data[:external_url] = value
    end

    def flagged_status=(value)
      @data[:flagged_status] = value.to_i
    end

    protected

    def volume
      @volume ||= Posting2.current_volume
    end

    def volume=(value)
      @volume = value
      client.query "UPDATE current_volume SET volume = #{value}"
    end

    private

    def client
      @client
    end

    def save_posting
      #TODO: What about SQL injection?
      data = Remote::Normalizer.new(@data).normalize

      q = %Q(
              INSERT INTO postings#{volume}
              SET #{ data.map{ |attr, value| "`#{ attr }`='#{ value }'" }.join(',') };
            )
      client.query q
    end

    def save_errors
      PostingValidationInfo.insert_from_hash(errors)
    end

    def after_save
      @id = client.query("SELECT LAST_INSERT_ID();").first.first[1]
      self.volume += 1 if @id % ::Posting::VOLUME_SIZE == 0

      time = Time.now.utc

      @redis = RedisHelper.hiredis
      @redis_reads = 0

      if @data[:source] == 'CRAIG'
        date_now = time.strftime("%Y-%m-%d")
        ip = @data[:transit_ip_address]
        @redis.write [ 'sadd', 'transit_ip_address', ip ]
        @redis.write [ 'incr', "stats:#{date_now}:#{Time.parse(@data[:created_at] || '-created_at-').strftime("%H")}:#{ip}" ]
        @redis.write [ 'incr', "stats:#{date_now}:#{@data[:category] || '-category-'}:#{ip}" ]
        @redis.write [ 'incr', "stats:#{date_now}:#{Time.at(timestamp).strftime("%Y-%m-%d") || '-Time.at_timestamp-'}:#{ip}" ]

        @redis_reads += 4
      end

      # StatisticByTransferedData.track source: source, category_group: @data[:category_group], ip: @data[:transit_ip_address], auth_token: auth_token, direction: :in, data_size: @data.to_json.bytesize

      @redis.write [ 'incr', "stats:#{@data[:source]}:added:#{time.to_i / 60 * 60}" ] # keys tied to minutely timestamps

      time = Time.now

      @redis.write [ 'incr', "stats:total:added:day:#{ time.strftime('%d.%m.%Y') }" ]
      @redis.write [ 'incr', "stats:total:added:hour:#{ time.strftime('%d.%m.%Y:%H') }" ]
      @redis.write [ 'incr', "stats:total:added:minute:#{ time.strftime('%d.%m.%Y:%H:%M') }" ]
      @redis.write [ 'incr', "stats:total:added:second:#{ time.strftime('%d.%m.%Y:%H:%M:%S') }" ]

      @redis_reads += 5

      @redis_reads.times { |_| @redis.read }

      LiveLovely.track(@data[:annotations], @data[:price]) if @data[:source] == 'CRAIG' && @data[:category_group] == 'RRRR'

      # unless source == 'CARSD'
      #   redis_key = "#{@data[:source]}:#{@data[:category]}:#{@data[:external_id]}"
      #
      #   if RedisHelper.get_redis.sismember("updated_postings:origins:#{ Date.today }", redis_key) or RedisHelper.get_redis.sismember("updated_postings:origins:#{ Date.today - 1.day }", redis_key)
      #     RedisHelper.get_redis.incr("updates:#{@data[:source]}:#{@data[:category]}:#{ Date.today }")
      #
      #     if @id.present?
      #       Posting2.connection.query "UPDATE postings#{ Posting2.current_volume } SET is_update = TRUE WHERE id = #{ @id }"
      #     end
      #   else
      #     RedisHelper.get_redis.sadd "updated_postings:origins:#{ Date.today }", redis_key
      #   end
      # end

      # save_annotations if source == "APTSD"
      #update_location unless ['BKPGE', 'OODLE'].include?(@data[:source]) #if @data[:source] == 'CRAIG'

      if @data[:zipcode].present? && @data[:geolocation_status] != Posting::GeoStatus::TO_LOCATE
        ZipsTracker.track(@data[:zipcode], source, @data[:state], @data[:category_group], @redis)
      else
        ZipsTracker.track_empty(@redis)
      end

      StatisticByMetro.track(@data[:metro], @data[:category]) if @data[:source] == 'CRAIG' && @data[:metro].present?

      if PostingConstants::TRACK_CARMAKER_SOURCES.include?(source) && @data[:annotations] && @data[:annotations]["make"].present?
        Carmaker.track(@data[:annotations]["make"], source)
      end
    end

    def save_annotations
      return unless Annotation::PROCESSING_ENABLED

      if @data.has_key?(:annotations) && @data[:annotations].keys.present?
        RedisHelper.get_redis.rpush(Annotation::QUEUE_NAME, @id) if @id.present?
      end
    end

    def fill_australian_locations
      if @data[:zipcode].present?
        @data[:zipcode] = "0#{@data[:zipcode]}" if @data[:zipcode].to_s.size == 3
        @data[:zipcode] = "AUS-#{@data[:zipcode]}" unless @data[:zipcode].include?('AUS-')

        locations = AustralianZipcode.find_by(zipcode: @data[:zipcode])
        if locations
          @data[:metro] = locations.metro
          @data[:state] = locations.state
          @data[:country] = locations.country
          @data[:geolocation_status] = PostingGeoStatuses::GeoStatus::LOCATED
        end
      end
    end

    # ??? ONLY CRAIG ???
    #def update_location
    #  SULO7.info @data[:source]
    #  if @data[:lat].blank? && @data[:long].blank?
    #    SULO7.info "lat long blank"
    #    if source_loc
    #      SULO7.info "source_loc not blank"
    #      locations = location_field
    #      locations << "lat"
    #      locations << "`long`"
    #      q = %Q(SELECT #{locations.join(',')} FROM CL_Locations WHERE source_loc="#{ source_loc }" ;)
    #      fields = client.query(q).first
    #      fields["geolocation_status"] = Posting::GeoStatus::LOCATED
    #      update_fields fields
    #    else
    #      SULO7.info "source_loc blank"
    #    end
    #  end
    #end

    # used in update_location only
    #def update_fields(new_data)
    #  if new_data
    #    update = new_data.map{ |attr, value| "`#{ attr }`='#{ value }'" }.join(',')
    #    update += " WHERE id=#{@id}"
    #    q = %Q(UPDATE postings#{volume} SET #{update};)
    #    client.query q
    #  end
    #end

    # used in update_location only
    #def location_field
    #  %w(accuracy country state metro region county city locality zipcode)
    #end

    public

    def auth_token
      @auth_token
    end

    #TODO: Do we really need all this getters???
    def id
      @id
    end

    def source_loc
      if @data[:annotations]
        @source_loc ||= @data[:annotations]["source_loc"]
      end
    end

    def timestamp
      @data[:timestamp]
    end

    def external_id
      @data[:external_id]
    end

    def external_url
      @data[:external_url]
    end


    def updated_at
      @data[:updated_at]
    end

    def category
      @data[:category]
    end

    def source
      @data[:source]
    end

    def status
      @data[:status]
    end

    def state
      @data[:posting_state]
    end

    def flagged_status
      @data[:flagged_status].to_i
    end
  end
end
