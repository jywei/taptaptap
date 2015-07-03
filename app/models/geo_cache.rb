class GeoCache < ActiveRecord::Base
  # fetch locations by formatted_address
  serialize :location_hash, Hash

  validates :formatted_address, :lat, :long, :accuracy, :location_hash, :hits, presence: true

  LOCATION_FIELDS = %w(country state metro region county city locality zipcode)

  after_create :increment_requests
	
  def self.fetch_locations(formatted_address)
    if formatted_address
      row = find_by_formatted_address(formatted_address)      
      if row
        row.update_attributes(hits: row.hits + 1)
        row  
      else
        if RequestsToGeocode.can_request?
          geocodes = Geocoder.search(formatted_address).first
          if geocodes
            lat_lng = geocodes.data["geometry"]["location"]
            locations = GeoApi.batch_locations([{'latitude' => lat_lng["lat"], 'longitude' =>lat_lng["lng"]}]).first if lat_lng
            if locations
              locations.select!{ |item| item if LOCATION_FIELDS.include? item }
              locations["formatted_address"] = geocodes.data["formatted_address"]

              create(
                {
                  formatted_address: formatted_address,
                  lat:               lat_lng["lat"],
                  long:              lat_lng["lng"],
                  accuracy:          self.accuracy(locations),
                  location_hash:     locations,
                  hits:              1   
                }
              )
            end
          end
        end 
      end
    end   
	end

  def self.accuracy(location)
    res = 0
    res = 1 if location.has_key? "country"
    res = 2 if location.has_key? "state"
    res = 3 if location.has_key? "metro"
    res = 4 if location.has_key? "region"
    res = 5 if location.has_key? "county"
    res = 6 if location.has_key? "city"
    res = 7 if location.has_key? "locality"
    res = 8 if location.has_key? "zipcode"
    res
  end  

  private

  def increment_requests
    timestamp = Time.now.to_i
    row = RequestsToGeocode.find_by_timestamp_begin(timestamp)
    if row
      row.update_attributes(count: row.count + 1)
    else
      RequestsToGeocode.new({timestamp_begin: timestamp,count: 1}).save
    end   
  end  

end
