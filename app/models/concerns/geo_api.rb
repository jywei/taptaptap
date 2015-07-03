class GeoApi 
  def self.locations(params)
    params = params.map{|attr, val| "#{attr}=#{val}" if val}.compact.join("&")
    response = GeoApi.fetch_locations(GEO_LOCATION_URL + "/?" + params)
    response = JSON.parse(response).symbolize_keys
   
    return {} unless response[:success]
    response.except(:success)
  end

  def self.fetch_locations(url)
    RestClient.get(url)
  end

  def self.batch_locations(coordinates)
    @uri = URI("http://geolocator.3taps.com")
    http = Net::HTTP.new(@uri.host, @uri.port)
    request = Net::HTTP::Post.new('/batch_reverse/')
    request.add_field('Content-Type', 'application/json')

    request.body =  {coords: coordinates}.to_json
    response = http.request(request)

    JSON.parse(response.body)
  rescue
    []
  end
end
