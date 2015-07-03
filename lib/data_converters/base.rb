module DataConverters
  class Base
    ATTRIBUTES = [:state, :location, :annotations, :images, :flagged_status]

    DEFAULT_STATE = 'available'

    attr_reader :data, :errors

    class << self
      # called in class itself
      def convert(*attributes)
        const_set :ATTRIBUTES, ATTRIBUTES | attributes
      end
    end

    def initialize(data, client = nil)
      @data = data
      @client = client
      @errors = {}
    end

    # called in processor class
    def convert
      p "converter call"

      self.class::ATTRIBUTES.each do |attribute|
        self.send(attribute)
      end

      @data.to_hash.symbolize_keys
    end

    def error_on(attr)
      @errors[attr] || []
    end

    protected

    def state
      if data[:state].present?
        data[:posting_state] = data[:state]
        data.delete(:state)
      else
        data[:posting_state] = DEFAULT_STATE
      end
    end

    def location
      if data[:location]
        data.merge!(data[:location])
        data.delete(:location)
      end
    end

    def annotations
      if data[:annotations]
        data[:annotations].to_hash.each do |k, v|
          data[:annotations][k] = v.to_s[0...1000]
        end
      else
        {}
      end
    end

    def images
      data[:images] ||= []
      if data[:images].first.is_a? String
        add_error :images, false
        data[:images].map! { |image| {full: image} }
      end
    end

    def flagged_status
      data[:flagged_status] ||= 0
    end

    def add_error(attr, error)
      @errors[attr] ||= []
      @errors[attr] << error
    end
  end
end
