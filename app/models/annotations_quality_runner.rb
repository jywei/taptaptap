class AnnotationsQualityRunner
  STOP_FILE = "log/kill_annotations_quality_runner.txt"
  BATCH_SIZE = 5_000
  COOLDOWN = 2.seconds

  def self.quality_of(posting)
    calculates = CalculateAnnotation.where(source: posting[:source], category: posting[:category]).load

    return nil if calculates.blank?

    c = calculates.inject(0.0) { |sum, i| sum += i['weight'].to_f }
    quality = 0.0

    return quality unless posting[:annotations].present?

    calculates.each do |calc|
      quality += calc['weight'].to_f if posting[:annotations].has_key? calc['annotation']
    end

    if c == 0
      0
    else
      ((quality.to_f / c) * 100).round
    end
  end

  def self.perform(volume = nil)
    volume = Posting2.current_volume if volume.blank?

    puts "starting working on #{ volume } volume..."

    while true do
      _time = Time.now

      postings = Posting2.connection.query("SELECT id, source, category, annotations, transit_ip_address, created_at FROM postings#{volume} WHERE annotations_quality IS NULL LIMIT #{BATCH_SIZE}").to_a

      qualities = {}
      missing_calculates = []

      postings.each do |posting|
        posting.symbolize_keys!
        posting[:annotations] = Oj.load(posting[:annotations]) if posting[:annotations].present? and posting[:annotations].is_a? String

        calculated_quality = quality_of(posting)

        # INDEE hack
        calculated_quality = 0 if posting[:source] == 'INDEE'

        if calculated_quality.present?
          qualities[posting[:id]] = calculated_quality
          posting[:quality] = calculated_quality
        else
          missing_calculates << "No annotations calculates found for source #{posting[:source].inspect} and category #{posting[:category].inspect}"
        end
      end

      QualityStatistic.track(postings, :annotations)

      missing_calculates.uniq.each { |msg| SULO9.error msg }

      unless qualities.empty?
        Posting2.connection.query("INSERT INTO postings#{volume} (id, annotations_quality) VALUES #{qualities.map { |id, q| "(#{id}, #{q})" }.join ','} ON DUPLICATE KEY UPDATE annotations_quality = VALUES(annotations_quality)")
      end

      puts "#{Time.now} :: processed #{qualities.size} postings from #{volume} volume in #{ Time.now - _time } seconds"

      if File.exists?(STOP_FILE)
        puts "Removing #{ STOP_FILE } file and stopping the loop"
        %x[rm -f #{ STOP_FILE }]
        break
      end

      sleep COOLDOWN
    end
  end
end
