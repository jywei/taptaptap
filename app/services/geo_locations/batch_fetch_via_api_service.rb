class GeoLocations::BatchFetchViaApiService
  attr_accessor :postings

  def initialize(postings)
    @postings = postings
  end

  def perform
    time = Time.now
    locations = GeoApi.batch_locations(coordinates)
    p "geoloc time: #{Time.now - time} s"

    id = @postings.first['id']
    volume = id.to_i / 1_000_000
    volume -= 1 if id.to_i % 1_000_000 == 0
    Posting.table_name = "postings#{volume}"
    locs = {country: nil, state: nil, metro: nil, region: nil, county: nil, city: nil, locality: nil, zipcode: nil}

    posting_updates = []
    posting_stats = []

    redis = RedisHelper.hiredis

    postings.each_with_index do |posting, index|
      attrs = {}
      if attrs = locations[index]
        attrs.delete('success')
        attrs.delete('error')
        attrs = locs.merge attrs.symbolize_keys
        attrs[:accuracy] = accuracy(attrs)
        attrs[:geolocation_status] = Posting::GeoStatus::LOCATED
      else
        attrs = {geolocation_status: Posting::GeoStatus::TO_LOCATE}
      end
      time = Time.now
      # RecentAnchor.update_precise_anchor(posting['id'])
      Posting.where(id: posting['id']).update_all(attrs)
      #store last zip's date to redis
      ZipsTracker.track(attrs[:zipcode], posting['source'], posting['state'], posting['category_group'], redis) if attrs[:zipcode].present?

      StatisticByMetro.track(attrs[:metro], posting['category']) if posting['source'] == 'CRAIG' && attrs[:metro].present?

      posting_updates << Time.now - time
      begin
#        time = Time.now
#        if ps = PostingStat.where(posting_id: posting['id']).first
#          ps.update_attribute(:located_at, Time.now.to_s(:db))
#        end
#        posting_stats << Time.now - time
      rescue Exception => e
        SULO3.error "location error:"
        SULO3.error e.message
        SULO3.error e.backtrace.join("\n")
      end
    end

    p "Posting update time: #{posting_updates.inject{|sum, x| sum + x}} seconds"
#    p "Posting stats update time: #{posting_stats.inject{|sum, x| sum + x}} seconds"

  end

  private

  def coordinates
    postings.map do |p|
      {'latitude' => p['lat'], 'longitude' => p['long']}
    end
  end

  def accuracy(locs)
    res = nil

    res = 1 if locs[:country].present?

    res = 2 if locs[:state].present?

    res = 3 if locs[:metro].present?

    res = 4 if locs[:region].present?

    res = 5 if locs[:county].present?

    res = 6 if locs[:city].present?

    res = 7 if locs[:locality].present?

    res = 8 if locs[:zipcode].present?

    res
  end
end
