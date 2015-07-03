class GeoLocations::FetchViaApiService
  attr_accessor :posting, :lat, :long

  def initialize(posting, lat, long)
    @posting = posting
    @lat = lat
    @long = long
  end

  def perform
    data = GeoApi.locations({
      latitude: lat,
      longitude: long
    })
    posting.update_attributes(data)
  end
end
