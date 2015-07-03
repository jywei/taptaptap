# fetches missing location values from `locations` table and merges into posting object

module GeoLocations
  class ProceedDataService
    attr_accessor :object, :location, :posting

    def initialize object, location
      @object = object
      @location = location
      @posting = {}
    end

    def perform
      Location::LEVELS.each do |level|
        posting[level] = location[level]
      end

      #self.class.trace_execution_scoped(['Custom/location_service/posting_assignments']) do
      posting['lat'] = location['lat']
      posting['long'] = location['long']
      posting['accuracy'] = location['accuracy']
      if location['bounds'].present?
        posting['min_lat'] = location['bounds']['min_lat']
        posting['max_lat'] = location['bounds']['max_lat']
        posting['min_long'] = location['bounds']['min_long']
        posting['max_long'] = location['bounds']['max_long']
      end
      #end

      #self.class.trace_execution_scoped(['Custom/location_service/complete_location']) do
      complete_location_fields if need_location_complete?
      #end

      #self.class.trace_execution_scoped(['Custom/location_service/posting_save']) do
      merge_geo_data_into_object
      #end
    end

    private


    def need_location_complete?
      value_found = false
      Location::LEVELS.reverse.each do |level|
        value_found = true and next if location[level].present?
        return true if value_found && location[level].blank?
      end
      false
    end

    def complete_location_fields
      location[:zipcode] = "USA-#{location[:zipcode]}" if location[:zipcode] && !(/^USA-.*/.match(location[:zipcode]))

      precisest_location_level = nil
      #self.class.trace_execution_scoped(['Custom/location_service/location_level']) do
      precisest_location_level = Location::LEVELS.select {|level| posting[level].present?}.last
      #end
      precisest_location_code = nil
      #self.class.trace_execution_scoped(['Custom/location_service/location_code']) do
      precisest_location_code = posting[precisest_location_level]
      #end
      location_with_details = nil
      #self.class.trace_execution_scoped(['Custom/location_service/location_details']) do
      location_with_details = Location.find_by(code: precisest_location_code)
      #end

      return unless location_with_details
      #self.class.trace_execution_scoped(['Custom/location_service/location_iterations']) do
      Location::LEVELS.each do |level|
        location[level] = location_with_details.send(level)
        posting[level] = location_with_details.send(level)
      end
      #end
    end

    def merge_geo_data_into_object
      location.each do |attr, value|
        object.send("#{attr}=", value) if object.respond_to?(attr)
      end
    end
  end
end