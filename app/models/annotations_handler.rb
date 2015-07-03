class AnnotationsHandler
  def self.process(options = { get_sample: true })
    __started_at = Time.now

    current_volume = Posting2.current_volume

    puts

    chosen_volume = [ current_volume - 1, FirstVolume.first_volume ].max
    last_processed_volume = RedisHelper.get_redis.get('annotations_handler:last_processed_volume')

    volume = last_processed_volume || chosen_volume
    RedisHelper.get_redis.set('annotations_handler:last_processed_volume', volume)

    i = 0

    filter_columns = %w(source category state metro region county city locality zipcode)

    # get all the filter columns having annotations in postings
    filters = Posting2.connection.query("SELECT #{ filter_columns.join(', ') } from postings#{volume} WHERE annotations IS NOT NULL GROUP BY #{ filter_columns.join(', ') }").to_a

    filters.each do |filter|
      i += 1
      print "\rfilter ##{ i } / #{ filters.size }"

      # get all the annotations' names
      annotations = Posting2.connection.query("SELECT annotations FROM postings#{volume} WHERE #{ (filter.map { |k, v| "`#{k}` = '#{ActionController::Base.helpers.sanitize v}'" }).join ' AND ' } AND annotations IS NOT NULL").to_a

      # get all the postings in this filters set
      total_postings = annotations.size

      if options[:get_sample]
        samples = {}

        annotations.map! do |a|
          d = Oj.load(a['annotations'])

          next [] if d.blank?

          samples.merge!(d) { |_, old, new| old.blank? ? new : old }
          d.keys
        end
      else
        annotations.map! { |a| Oj.load(a['annotations']).keys }
      end

      # count annotations in those postings
      counts = annotations.flatten.inject(Hash.new(0)) { |total, e| total[e] += 1; total }

      counts.each do |annotation, count|
        if options[:get_sample]
          sample = samples[annotation]

          sample = sample.to_s[0..250].gsub(/[^\w]\w+\s*$/, '...') if sample.present? and sample.length > 250
        else
          sample = nil
        end

        # create CalculateAnnotation
        record = CalculateAnnotation.find_or_create_by(source: filter['source'], category: filter['category'], annotation: annotation)

        count = (record.count_occurrences || 0) + count
        total_count = (record.total_count || 0) + (total_count || 0)

        record.update_attributes count_occurrences: count, total_count: total_count, sample_value: sample

        # create AnnotationLocation
        criteria = Hash[filter_columns.map { |c| [ c.to_sym, filter[c] ] }]

        # custom criteria
        criteria[:annotation] = annotation
        criteria[:volume] = volume

        record = AnnotationsLocation.find_or_create_by(criteria)

        count = (record.count_occurrences || 0) + count
        total_count = (record.total_count || 0) + (total_count || 0)

        record.update_attributes count_occurrences: count, total_count: total_count
      end
    end

    __end_time = Time.now

    puts "\nProcessed volume #{volume} in #{ __end_time - __started_at } seconds\n"
  end
end