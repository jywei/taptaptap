module Remote
  class Normalizer
    include ApplicationHelper

    ALLOWED_ATTRIBUTES = [
        :account_id, :annotations, :body, :category, :category_group, :created_at, :currency,
        :expires, :external_id, :external_url, :heading, :html, :images, :language, :price,
        :source, :status, :timestamp, :updated_at, :lat, :long, :country, :state, :metro,
        :region, :county, :city, :locality, :zipcode, :posting_state, :flagged_status, :deleted,
        :origin_ip_address, :transit_ip_address, :proxy_ip_address, :accuracy, :geolocation_status, :formatted_address, :auth_token
    ]

    def initialize(data)
      @data = data
    end

    def normalize
      @data[:created_at] ||= current_db_time
      @data[:updated_at] = current_db_time

      data = @data.clone
      data.keep_if { |key, value| ALLOWED_ATTRIBUTES.include? key }

      data[:images]      = escape(data[:images].to_yaml)
      data[:annotations] = escape(taps_serialize(data[:annotations]))
      data[:heading]     = escape(data[:heading].to_s)
      data[:price]       = data[:price].to_f  unless data[:price].nil?
      data[:country]     = escape(data[:country])  unless data[:country].nil?
      data[:state]       = escape(data[:state])    unless data[:state].nil?
      data[:metro]       = escape(data[:metro])    unless data[:metro].nil?
      data[:region]      = escape(data[:region])   unless data[:region].nil?
      data[:county]      = escape(data[:county])   unless data[:county].nil?
      data[:city]        = escape(data[:city])     unless data[:city].nil?
      data[:locality]    = escape(data[:locality]) unless data[:locality].nil?
      data[:body]        = data[:body] ? escape(data[:body]) : ''
      data[:expires]     = data[:expires] ? data[:expires].to_i : 0
      data[:accuracy]    = data[:accuracy] ? data[:accuracy].to_i : 0
      data[:timestamp]   = data[:timestamp] ? data[:timestamp].to_i : current_time.to_i
      data[:formatted_address]   = escape(data[:formatted_address]) unless data[:formatted_address].nil?
      data[:deleted]     = data[:deleted] == 'true' ? 1 : 0
      data[:lat]  ||= 0
      data[:long] ||= 0
      #data[:auth_token]    = escape(data[:auth_token]) unless data[:auth_token].nil?

      data
    end

    private

    def current_time
      @time ||= Time.now.utc
    end

    def current_db_time
      @db_time ||= current_time.to_s(:db)
    end

    def escape(data)
      Posting2.connection.escape(data)
    end
  end
end
