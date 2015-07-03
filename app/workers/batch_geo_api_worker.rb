class BatchGeoApiWorker
  @queue = :batch_geo_api

  def self.perform(postings)
    # Statistics::Tracker.trace_time(Statistics::BACKGROUND_TIME) do
      GeoLocations::BatchFetchViaApiService.new(postings).perform
    # end
  end
end
