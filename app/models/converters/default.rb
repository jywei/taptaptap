module Converters
  module Default
    DEFAULT_STATE = 'available'
    DEFAULT_STATUS = 'for_sale'

    def category_group
      category_group_by_group = nil

      Posting::CATEGORY_RELATIONS.each do |category_group, categories|
        category_group_by_group = category_group if categories.include? @posting[:category]
      end

      if category_group_by_group
        if @posting.has_key? :category_group
          if @posting[:category_group] != category_group_by_group
            add_error(:category_group, "#{posting_value(:category_group)} is improper for category #{@posting[:category]}")
          end
        else
          @posting[:category_group] = category_group_by_group
        end
      else
        if @posting.has_key?(:category_group)
          add_error(:category_group, "`#{@posting[:category_group].inspect}` is improper category_group")
        else
          add_error(:category, "could not match category `#{@posting[:category].inspect}` with any of category groups")
        end
      end
    end

    def _status
      @posting[:status] ||= DEFAULT_STATUS
    end

    def _state
      state = @posting[:state]

      if state.present?
        @posting[:posting_state] = state
        @posting.delete(:state)
      else
        @posting[:posting_state] = DEFAULT_STATE
      end
    end

    def location
      if @posting[:location]
        @posting.merge!(@posting[:location])
        @posting.delete(:location)
        @posting[:zipcode] = @posting[:zipcode].to_s if @posting.has_key? :zipcode
      end
    end

    def annotations
      if @posting[:annotations]
        @posting[:annotations].to_hash.each do |k, v|
          @posting[:annotations][k] = v.to_s[0...1000]
        end
      else
        {}
      end
    end

    def images
      @posting[:images] ||= []
      if @posting[:images].first.is_a? String
        add_error :images, false
        @posting[:images].map! { |image| {full: image} }
      end
    end

    def _flagged_status
      @posting[:flagged_status] = @posting[:flagged_status].to_i
    end
  end
end
