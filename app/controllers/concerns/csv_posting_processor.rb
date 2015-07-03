require 'csv'

class CSVPostingProcessor < PostingProcessor
  include ApplicationHelper

  def initialize client
    super client
  end

  def field_by_key(posting, key)
    return nil unless key
    field = posting
    key.to_s.split('>>').each do |k|
      field = field[k]
    end
    field
  end

  def arrays_to_strings(annotations, prefix, value)
    if value.is_a? Array
      annotations[prefix] = value.join(', ')
    else # Hash
      value.each do |k,v|
        key = prefix << "." << k
        if v.is_a?(Array) || v.is_a?(Hash)
          annotations = arrays_to_strings(annotations, key, v)
        else
          annotations[key] = v
        end
      end
    end
    annotations
  end

  def process(postings, remote_ip, source = nil)
    source ||= postings.first[:source]

    parsing_config = parsing_configuration(source)
    parsed_postings = postings.map do |posting|
      annotations = {}
      parsing_config[:annotations][:field].to_s.split('|').map do |field|
        field_arr = field.split(',')
        field_name = field_arr[0]
        field_value = field_by_key(posting, field_arr[1])
        if field_value.is_a?(Array) || field_value.is_a?(Hash)
          annotations = arrays_to_strings(annotations, field_name, field_value)
        else
          annotations[field_name] = field_value
        end
      end

      bounds_fields = [:min_lat, :max_lat, :min_long, :max_long]
      bounds = bounds_fields.map {|field| field_by_key(posting, parsing_config[field][:field])}
      location_fields = [:lat, :long, :accuracy, :country, :state, :metro, :region, :county, :city, :locality, :zipcode, :formatted_address]
      location = {}
      location_fields.each {|field| location[field] = field_by_key(posting, parsing_config[field][:field])}
      location[:bounds] = bounds

      regular_fields = [:source, :category, :category_group, :external_id, :external_url, :heading, :body, :html, :expires, :language, :price, :currency, :status, :flagged, :deleted, :immortal]
      special_fields = [:images, :location, :annotations]

      if source == 'REMLS'
        images = field_by_key(posting, parsing_config[:images][:field]).split(',').map{|url| Hash[*['full', url]]}
        timestamp = DateTime.strptime(field_by_key(posting, parsing_config[:timestamp][:field]), '%m/%d/%Y %r').to_i
        special_fields << :timestamp
      else
        images_data = field_by_key(posting, parsing_config[:images][:field])
        images = images_data.map{|url| Hash[*['full', url]]} if images_data
        regular_fields << :timestamp
      end


      parsed_posting = {}
      regular_fields.each {|field| parsed_posting[field] = parsing_config[field][:default] || eval(parsing_config[field][:ruby_code].to_s) || field_by_key(posting, parsing_config[field][:field]) }
      special_fields.each {|field| parsed_posting[field] = parsing_config[field].try(:[], :default) || eval(parsing_config[field].try(:[], :ruby_code).to_s) || eval(field.to_s)}

      parsed_posting
    end

    timestamps = []
    error_responses = []
    ids = {}
		volume = Posting2.current_volume

    parsed_postings.each_with_index do |posting_data, index|
      posting_data = posting_data.with_indifferent_access
      error_response = nil
      validation_errors = {}

      posting = nil
      a = []
      time = Time.now.to_s(:db)

      a << posting_data[:account_id]
      location = posting_data['location'] || {}

      annotations = posting_data[:annotations] ? posting_data[:annotations].to_hash : {}
      a << @client.escape(taps_serialize(annotations))

      body = if posting_data[:body]
               @client.escape(posting_data[:body])
             else
               '' # EBAYM has no body
             end
      a << body
      a << posting_data[:category]
      validation_errors['category'] = false unless Posting::CATEGORIES.include? posting_data[:category]
      a << Posting::CATEGORY_RELATIONS_REVERSE[posting_data[:category]]
      a << time
      a << posting_data[:currency]
      expires = if posting_data[:expires]
                  posting_data[:expires].to_i
                else
                  0
                end
      a << expires
      a << posting_data[:external_id]
      a << posting_data[:external_url]
      a << @client.escape(posting_data[:heading].to_s)
      a << posting_data[:html]

      images = posting_data[:images] ? posting_data[:images] : []
      if images.first.is_a? String
        validation_errors['images'] = false
        images.map!{|image| {full: image}}
      end
      a << @client.escape(images.to_yaml)
      a << posting_data[:language]
      a << posting_data[:price]
      a << posting_data[:source]
      validation_errors['source'] = false unless Posting::SOURCES.include? posting_data[:source]

      status = if posting_data[:source] == 'CRAIG'
                 Posting::CRAIG_STATUSES_BY_CAT[annotations['source_subcat'].to_s.split('|').last]
               else
                 if posting_data[:status].kind_of? Hash
                   posting_data[:status].keys.first
                 else
                   posting_data[:status]
                 end
               end
      status = 'for_sale' if status == ''
      status = 'for_sale' if status.nil?
      a << status
      timestamp = if posting_data[:timestamp] # sometimes comes 'false'
                    posting_data[:timestamp].to_i
                  else
                    Time.now.to_i
                  end
      a << timestamp
      timestamps << timestamp
      a << time

      accuracy = nil
      accuracy = 8 if location['zipcode'].present?

      if location['zipcode'].present? && (location['lat'].blank? || location['long'].blank?)
        lat_and_long = ZipCode.find_by_zipcode(location['zipcode'])
        if lat_and_long.present?
          location['lat'] = lat_and_long['lat']
          location['long'] = lat_and_long['long']
        end
      end

      a << location['lat']
      a << location['long']
      a << location['country']
      a << location['state']
      a << location['metro']
      a << location['region']
      a << location['county']
      a << location['city']
      a << location['locality']
      a << location['zipcode']
      a << location['formatted_address']

      state = posting_data['state']
      state = 'available' if state.nil? || state == ''
      a << state

      a << posting_data['flagged_status'] || 0
      a << posting_data['origin_ip_address']
      a << remote_ip

      a << accuracy

      geolocation_status = accuracy == 8 ? 1 : 0

      a << geolocation_status

      @client.query %Q(
              INSERT INTO postings#{volume} (`account_id`,`annotations`,
                `body`, `category`, `category_group`,
                `created_at`, `currency`, `expires`,
                `external_id`, `external_url`, `heading`,
                `html`, `images`, `language`, `price`,
                `source`, `status`, `timestamp`, `updated_at`,
                `lat`, `long`, `country`, `state`, `metro`, `region`, `county`, `city`, `locality`, `zipcode`, `formatted_address`,
                `posting_state`, `flagged_status`, `origin_ip_address`, `transit_ip_address`, `accuracy`, `geolocation_status`
             )
              VALUES ('#{a.join("','")}');
            )
      r = @client.query("SELECT LAST_INSERT_ID();")
                                                 #id = r.first[0] # for AR::Base.connection result
      id = r.first.first[1] # for mysql result


      if id % Posting::VOLUME_SIZE == 0
        volume += 1
        @client.query "UPDATE current_volume SET volume = #{volume}"
      end

      @client.query "INSERT INTO posting_validation_infos (posting_id, created_at, updated_at, #{validation_errors.keys.join(',')}) VALUES (#{id}, '#{time}', '#{time}', #{validation_errors.values.join(',')})" if validation_errors.has_value?(false)
     	SULO6.error "csv posting processor" if validation_errors.has_value?(false)

      ids[posting_data[:external_id]] = id
    end

    if timestamps.empty?
      error_responses << "No postings found"
    else
      timestamp_values = timestamps.uniq.map {|t| "(#{t})"}.join(',')
      @client.query %Q(INSERT IGNORE timestamps VALUES #{timestamp_values};)
      @client.close
    end

    response = {error_responses: error_responses, wait_for: 0}
    response[:ids] = ids unless ids.empty?

    response
  end

  private

  def parsing_configuration(source)
    fields_array = CSV.parse(File.read("#{Rails.root}/lib/data/#{source}_parsing_configuration.csv")).map do |field_data|
      parsing_field = field_data[1] && field_data[1].to_sym
      [field_data[0].to_sym, {field: parsing_field, default: field_data[2], ruby_code: field_data[3]}]
    end
    Hash[*fields_array.flatten]
  end


end
