class CalculateAnnotation < ActiveRecord::Base
  establish_connection("taps_stat_#{ Rails.env }")

  def self.fill
    current_volume = Posting2.current_volume

    puts

    volume = [ current_volume - 1, FirstVolume.first_volume ].max

    i = 0

    # get all the (source, category) pairs having annotations in postings
    filters = Posting2.connection.query("SELECT source, category from postings#{volume} WHERE annotations IS NOT NULL GROUP BY source, category").to_a

    filters.each do |filter|
      i += 1
      print "\rfilter ##{ i } / #{ filters.size }"

      # get all the annotations' names
      annotations = Posting2.connection.query("SELECT annotations FROM postings#{volume} WHERE source = '#{ filter['source'] }' AND category = '#{ filter['category'] }' AND annotations IS NOT NULL").to_a

      # get all the postings in this category and source
      total_postings = annotations.size

      samples = {}

      annotations.map! do |a|
        d = Oj.load(a['annotations'])

        next [] if d.blank?

        samples.merge!(d) { |_, old, new| old.blank? ? new : old }
        d.keys
      end

      # count annotations in those postings
      counts = annotations.flatten.inject(Hash.new(0)) { |total, e| total[e] += 1; total }

      counts.each do |annotation, count|
        record = find_or_create_by(source: filter['source'], category: filter['category'], annotation: annotation)

        sample = record.sample.to_s + samples[annotation]
        sample = sample.to_s[0..250].gsub(/[^\w]\w+\s*$/, '...') if sample.present? and sample.length > 250

        count = (record.count_occurences || 0) + count

        total_postings = (record.total_postings || 0) + total_postings

        record.update_attributes count_occurrences: count, total_count: total_postings, sample_value: sample
      end
    end
  end
end
