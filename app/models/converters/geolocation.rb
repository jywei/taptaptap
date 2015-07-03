module Converters
  module Geolocation
    def accuracy
      if use_geolocation_module
        @posting[:accuracy] = if @posting[:zipcode].present?
                                8
                              else
                                add_warning(:formatted_address, 'should be present') unless @posting[:formatted_address].present?

                                commas = (@posting[:formatted_address] || '').count(',')

                                if commas == 2
                                  6
                                elsif commas == 1
                                  2
                                elsif commas == 0
                                  1
                                else
                                  nil
                                end
                              end
      end
    end

    def geolocation_status
      @posting[:geolocation_status] = Posting::GeoStatus::NOT_FOR_LOCATION

      if use_geolocation_module && @posting[:zipcode] =~ /^\d+$/
        lat_and_long = ZipCode.find_by_zipcode(@posting[:zipcode])
        if lat_and_long.present?
          @posting[:lat] = lat_and_long['lat']
          @posting[:long] = lat_and_long['long']
          @posting[:geolocation_status] = Posting::GeoStatus::TO_LOCATE
        end
      end
    end
  end
end
