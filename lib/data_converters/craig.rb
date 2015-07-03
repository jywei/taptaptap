module DataConverters
  class Craig < DataConverters::Base
    include DataConverters::LocationConverter

    SOURCE = 'CRAIG'
    DEFAULT_STATUS = 'for_sale'
    NOT_ALLOWED_STATUS = 'offered'

    convert :source, :status, :geolocation_status, :price

    protected

    def source
      data[:source] = SOURCE
    end

    def status
      data[:status] = ::Posting::CRAIG_STATUSES_BY_CAT[data[:annotations]['source_subcat'].to_s.split('|').last]
      data[:status] = DEFAULT_STATUS if data[:status] == '' || data[:status].nil?
    end

    def price
      data[:price] = nil if data[:price] < 0
    end

    #def accuracy
    #  data[:accuracy] =
    #end

    def category_group
      Posting::CATEGORY_RELATIONS_REVERSE[data[:category]]
    end

    def geolocation_status
      data[:geolocation_status] = Posting::GeoStatus::TO_LOCATE
      if data[:lat] && data[:long]
        location_from_database = CraigLocation.where(lat: data[:lat], long: data[:long]).first
        if location_from_database
          location_from_database.location.each { |k, v| location[k] = v }
          data[:geolocation_status] = Posting::GeoStatus::LOCATED_CL_BY_SPREADSHEET
        end
      end
    end
  end
end