class LastVolume
  class << self
    def last_volume
      Posting2.connection.query("SELECT volume from last_volume;").try(:first).try(:[], 'volume').try(:to_i) || 0
    end

    def bump_1_table
      last = self.last_volume
      connection = Posting2.connection

      PostingThreshold.dropped_volume(last)

      connection.query(SystemData.create_table_script(last+1))

      connection.query("UPDATE last_volume SET volume=#{last+1};")

      SystemEvent.create event: "volume #{last+1} created"

      StatisticByVolume.update_stats!
    end
  end
end
