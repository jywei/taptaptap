class FirstVolume
  class << self
    def first_volume
      Posting2.connection.query("SELECT volume from first_volume;").try(:first).try(:[], 'volume').try(:to_i)
    end

    def bump_first_volume(number)
      connection = Posting2.connection

      first_vol = first_volume

      connection.query("UPDATE first_volume SET volume=#{number};")

      first_vol.upto(number - 1) do |i|
        connection.query("drop table postings#{i};")
      end
    end

    def bump_1_table
      connection = Posting2.connection
      first_vol = first_volume

      PostingThreshold.dropped_volume(first_vol)

      connection.query("UPDATE first_volume SET volume=#{first_vol + 1};")
      connection.query("drop table postings#{first_vol};")

      SystemEvent.create(event: "bumped first volume to #{FirstVolume.first_volume}")

      StatisticByVolume.update_stats!
      SystemMonitor.clean_updated_counts(first_vol)

      # SystemMonitor.clean_old_latency_statistics

      LastVolume.bump_1_table

      #remove old data from annotations_locations
      # AnnotationsLocation.bump_old_data(first_vol)

      bump_external_id_volumes(first_vol+ 1)
      bump_insert_profilers(first_vol + 1)
    end

    private

    def bump_external_id_volumes(volume)
      if volume >= first_volume
        first_posting = Posting2.connection.query("SELECT DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at FROM postings#{volume} order by id asc limit 1").to_a.first

        if first_posting.present?
          # SULO8.error "NOTE TO REMOVE RECORDS FROM external_id_volumes WITH THIS QUERY: #{"DELETE FROM external_id_volumes WHERE created_at < '#{first_posting['created_at']}'"}"
          # TODO: Deal with all these records somehow. Either turn it off or make deletion quicker
          # Posting2.connection.query("DELETE FROM external_id_volumes WHERE created_at < '#{first_posting['created_at']}'")
        end
      end
    end

    def bump_insert_profilers(volume)
      if volume >= first_volume
        first_posting = Posting2.connection.query("SELECT DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at FROM postings#{volume} order by id asc limit 1").to_a.first
        Posting2.connection.query("DELETE FROM insert_profilers WHERE created_at < '#{first_posting['created_at']}'") if first_posting.present?
      end
    end
  end
end
