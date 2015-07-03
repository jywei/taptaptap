module DataConverters
  class Default < DataConverters::Base
    convert :accuracy, :geolocation_status

    protected

    def accuracy
      data[:accuracy] = nil
    end

    def geolocation_status
      data[:geolocation_status] = Posting::GeoStatus::NOT_FOR_LOCATION
    end
  end
end
