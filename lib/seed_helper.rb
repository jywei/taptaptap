class SeedHelper
  class << self
    def fix_sequence(model)
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{model.to_s.tableize}_id_seq RESTART WITH #{model.reorder('id DESC').first.id+1};")
    end

    def locations
      @locations ||= Location.all.to_a
    end

    def external_id
      @external_id ||= Posting.select('external_id').order('external_id DESC').first.try(:external_id).try(:to_i) || 0
      @external_id += 1
    end

    def fill_location_hash(location)
      location_hash = {}
      Location::LEVELS.each do |level|
        location_hash[level.to_sym] = location.send(level)
      end
      location_hash
    end

    def find_category_group(category)
      return category if Posting::CATEGORY_GROUPS.include? category
      Posting::CATEGORY_RELATIONS.select {|category_group, categories| categories.include? category}.keys.first
    end

    def random_postings(number)
      postings = []
      locations = SeedHelper.locations
      number.times.each do |index|
        sample_location = locations.sample
        location = SeedHelper.fill_location_hash(sample_location)
        heading = Random.alphanumeric(10)+Random.alphanumeric(Random.number(30))
        timestamp = Random.date(-365..0).to_time.to_i
        expires = timestamp + Random.number(30)*1.day
        category = Posting::CATEGORIES.sample
        category_group = SeedHelper.find_category_group(category)
        posting = {
          source: ['REMLS', 'EBAYC'].sample,#(Posting::SOURCES - ['HMNGS']).sample,
          category: category,
          category_group: category_group,
          location: location,
          external_id: SeedHelper.external_id,
          external_url: Random.alphanumeric,
          heading: heading,
          body: Random.paragraphs,
          timestamp: timestamp,
          created_at: Time.at(timestamp),
          updated_at: Time.at(timestamp),
          expires: expires,
          language: Random.chars('A'..'Z', 2),
          price: Random.number(10000),
          currency: Random.chars('A'..'Z', 3),
          annotations: {},
          status: Posting::STATUSES.sample,
          flagged: false,
          deleted: ['true', 'false'].sample,
          immortal: false,
          images: []
        }
        postings << posting
      end
      postings
    end
  end
end