class GeoApiWorker
  @queue = :geo_api

  def self.perform(posting_code, lat, long)
    posting = Posting.find_by_code(posting_code)
    GeoLocations::FetchViaApiService.new(posting, lat, long).perform if posting
  end
end
