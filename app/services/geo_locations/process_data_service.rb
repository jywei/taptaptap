# decides whether to fetch missing location values from `locations` table
# or retrieve locations data from preloaded hash based on `lat` and `long`

module GeoLocations
  class ProcessDataService
    attr_accessor :object, :location

    def initialize(object, location)
      @object = object
      @location = location
    end

    def perform
      return if location.blank?
      unless object.already_geolocated
        #self.class.trace_execution_scoped(['Custom/location_service/handle_location']) do
          GeoLocations::FetchPreloadedDataService.new(object, location['long'], location['lat']).perform
        #end
      else
        GeoLocations::ProceedDataService.new(object, location).perform
      end
      object
    end

  end
end
