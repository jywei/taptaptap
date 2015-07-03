class AnnotationsLocation < ActiveRecord::Base
  establish_connection("taps_stat_#{ Rails.env }")

  def self.fill(_volume = nil)
    i = 0

    last_processed_volume = RedisHelper.get_redis.get('annotations_handler:last_processed_volume')

    current_volume = Posting2.current_volume

    if last_processed_volume.blank?
      chosen_volume = [ current_volume - 1, FirstVolume.first_volume ].max
    else
      chosen_volume = last_processed_volume.to_i + 1
    end

    volume = _volume || chosen_volume

    if volume >= current_volume
      p "chosen to process volume ##{ volume } (current_volume is #{current_volume}). skipping it for now..."
      return
    end

    # get all the (source, category) pairs having annotations in postings
    filters = Posting2.connection.query("SELECT source, category from postings#{volume} WHERE annotations IS NOT NULL GROUP BY source, category").to_a

    filter_columns = %w(city country county locality metro region state zipcode)

    filters.each do |filter|
      i += 1
      print "\rfilter ##{ i } / #{ filters.size }"

      # get all the annotations' names
      annotations = Posting2.connection.query("SELECT annotations, #{filter_columns.join(',')} FROM postings#{volume} WHERE source = '#{ filter['source'] }' AND category = '#{ filter['category'] }' AND annotations IS NOT NULL").to_a

      by_zip = annotations.group_by { |e| e["zipcode"] }

      by_zip.map do |zipcode, hashes|
        query = <<-SQL
          INSERT INTO annotations_locations
            (source, category, annotation, #{filter_columns.join(',')}, count_occurrences, total_count, volume, created_at, updated_at)
          VALUES
        SQL

        counts = {}
        calculate_counts = {}

        if zipcode.nil?
          res = []

          hashes.each do |a|
            d = Oj.load(a['annotations'])

            next if d.blank?

            d.each do |annotation, value|
              res << {'annotation' => annotation, 'count_occurrences' => 1}.merge(a)

              #calculate_annotations
              if calculate_counts.has_key?(annotation)
                calculate_counts[annotation]['count_occurrences'] += 1
              else
                calculate_counts[annotation] = { 'count_occurrences' => 1 }
              end
            end
          end

          time = Time.now.to_s(:db)

          query += res.map do |d|
            <<-SQL
              (
                #{ quote(filter['source']) },
                #{ quote(filter['category']) },
                #{ quote(d['annotation']) },
                #{ quote(d['city']) },
                #{ quote(d['country']) },
                #{ quote(d['county']) },
                #{ quote(d['locality']) },
                #{ quote(d['metro']) },
                #{ quote(d['region']) },
                #{ quote(d['state']) },
                #{ quote('') },
                1,
                1,
                #{volume},
                #{ quote(time) },
                #{ quote(time) }
              )
            SQL
          end.join(',')

          query += <<-SQL
            ON DUPLICATE KEY
              UPDATE
                count_occurrences = count_occurrences + 1,
                total_count = total_count + 1,
                updated_at = VALUES(updated_at)
            ;
          SQL
        else
          hashes.each do |a|
            d = Oj.load(a['annotations'])

            next if d.blank?

            d.each do |annotation, value|
              if counts.has_key?(annotation)
                counts[annotation]['count_occurrences'] += 1

                #calculate_anootaions
                calculate_counts[annotation]['count_occurrences'] += 1
              else
                counts[annotation] = Hash[filter_columns.map { |k| [ k, a[k] || '' ] }]
                counts[annotation]['count_occurrences'] = 1
                counts[annotation]['zipcode'] = zipcode

                #calculate_anootaions
                calculate_counts[annotation] = {'count_occurrences' => 1}
              end
            end
          end

          time = Time.now.to_s(:db)

          query += counts.map do |annotation, d|
            <<-SQL
              (
                '#{ filter['source'] }',
                '#{ filter['category'] }',
                '#{ annotation }',
                #{ quote(d['city']) },
                #{ quote(d['country']) },
                #{ quote(d['county']) },
                #{ quote(d['locality']) },
                #{ quote(d['metro']) },
                #{ quote(d['region']) },
                #{ quote(d['state']) },
                #{ quote(d['zipcode']) },
                #{ d['count_occurrences'] || 0 },
                #{hashes.size || 0},
                #{volume},
                #{ quote(time) },
                #{ quote(time) }
              )
            SQL
          end.join(',')

          query += <<-SQL
            ON DUPLICATE KEY
              UPDATE
                count_occurrences = count_occurrences + VALUES(count_occurrences),
                total_count = total_count + VALUES(total_count),
                updated_at = VALUES(updated_at)
            ;
          SQL
        end

        begin
          # return query unless counts.empty?
          connection.execute query unless counts.empty? #don't execute empty queries
          fill_calculate_annotations(filter['source'], filter['category'], calculate_counts, hashes.size)
        rescue Exception => e
          p counts
          p query

          return e
        end
      end
    end

    RedisHelper.get_redis.set('annotations_handler:last_processed_volume', volume)
  end

  def self.remove_old_data
    query = <<-SQL
      DELETE FROM
        annotations_locations
      WHERE
        created_at <= '#{ (Time.now - 3.days).strftime("%Y-%m-%d") }'
    SQL

    connection.execute query
  end

  private

  def self.bump_old_data(volume)
    query = <<-SQL
      DELETE
        FROM annotations_locations
      WHERE volume = #{volume}
    SQL

    connection.execute query
  end

  def self.fill_calculate_annotations(source, category, calculate_counts, total_count)
    calculate_query = <<-SQL
      INSERT INTO calculate_annotations
        (source, category, annotation, count_occurrences, total_count)
      VALUES
    SQL

    calculate_query += calculate_counts.map do |annotation, data|
      <<-SQL
        (
          '#{ source }',
          '#{ category }',
          '#{ annotation }',
          #{ data['count_occurrences'] || 0 },
          #{total_count}
        )
      SQL
    end.join(',')

    calculate_query += <<-SQL
      ON DUPLICATE KEY
        UPDATE
          count_occurrences = count_occurrences + VALUES(count_occurrences),
          total_count = total_count + VALUES(total_count)
      ;
    SQL

    connection.execute calculate_query if calculate_query.size > 450 #don't execute empty queries
  end

  def self.quote(str)
    # if str && str != 'NULL'
      connection.quote(str)
    # else
    #   'NULL'
    # end
  end
end