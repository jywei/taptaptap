# based on `lat` and `long` values fetches missing locations data from preloaded hash
# if data absent makes call to geo API

module GeoLocations
  class FetchPreloadedDataService
    attr_accessor :object, :long, :lat, :key

    def initialize(object, long, lat)
      @object = object
      @long   = long
      @lat    = lat
      @key    = "#{long}__#{lat}"
    end

    def perform
      if preloaded_data.present?
        use_preloaded_data
      else
        use_async_geo_api
      end
    end

    private

    def preloaded_data
      @data ||= ::GEO_LOCATION_DATA[key]
    end

    def use_preloaded_data
      country, state, metro = preloaded_data
      object.country = country
      object.state = state
      object.metro = metro
    end

    def use_async_geo_api
      Resque.enqueue(GeoApiWorker, object.code, lat, long)
    end
  end
end
