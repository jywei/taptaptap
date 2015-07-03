class FieldsQualityRunner
  STOP_FILE = "log/kill_fields_quality_runner.txt"
  BATCH_SIZE = 10_000
  COOLDOWN = 10.seconds

  def self.quality_of(posting)
    fields_values = {
        category: 5,
        category_group: 5,
        source: 10,
        formatted_address: 2,
        phone: 5,
        external_id: 5,
        external_url: 5,
        heading: 5,
        body: 5,
        html: 5,
        price: 5,
        expires: 2.5,
        currency: 2.5,
        images: 2.5,
        status: 2.5,
        timestamp: 2.5,
        posting_state: 2.5,
        flagged_status: 2.5,
        origin_ip_address: 2.5
    }

    quality = (fields_values.map { |field, percent| posting[field].present? ? percent : 0.0 }).sum

    quality += 5.0 if posting[:annotations].present? and posting[:annotations][:source_account].present?
    quality += posting[:accuracy].to_f if posting[:accuracy].present?

    quality
  end

  def self.perform
    puts 'starting...'

    while true do
      prev_volume = [ FirstVolume.first_volume, Posting2.current_volume - 1 ].max

      [ prev_volume, Posting2.current_volume ].each do |volume|
        postings = Posting2.connection.query("SELECT * FROM postings#{volume} WHERE fields_quality IS NULL AND geolocation_status IN (#{Posting::GeoStatus::NOT_FOR_LOCATION}, #{Posting::GeoStatus::LOCATED}, #{Posting::GeoStatus::LOCATED_CL_BY_SPREADSHEET}) LIMIT #{BATCH_SIZE}").to_a

        qualities = {}

        postings.each do |posting|
          posting['annotations'] = Oj.load(posting['annotations']) if posting['annotations'].present?
          posting['images'] = YAML.load(posting['images']) if posting['images'].present?
          posting.deep_symbolize_keys!
          calculated_quality = quality_of(posting)
          qualities[posting[:id]] = calculated_quality || 'NULL'
          posting[:quality] = calculated_quality
          StatisticByEmptyImage.track(posting)
        end

        unless qualities.empty?
          QualityStatistic.track(postings, :fields)
          Posting2.connection.query("INSERT INTO postings#{volume} (id, fields_quality) VALUES #{qualities.map { |id, q| "(#{id}, #{q})" }.join ','} ON DUPLICATE KEY UPDATE fields_quality = VALUES(fields_quality)")
        end

        puts "processed #{qualities.size} postings from #{volume} volume"
      end

      if File.exists?(STOP_FILE)
        p "Removing #{ STOP_FILE } file and stopping the loop"
        %x[rm -f #{ STOP_FILE }]
        break
      end

      sleep COOLDOWN
    end
  end
end
