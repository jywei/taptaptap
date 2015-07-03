class Posting2
  class << self
    attr_accessor :conditions

    def connection
      @connection ||= Mysql2::Client.new(
          {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
      )

      is_alive = @connection.ping

      @connection = Mysql2::Client.new(
          {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
      ) unless is_alive

      @connection
    end

    def close_connection
      @connection.close if @connection
    end

    def default_anchor
      recent_anchor = RecentAnchor.anchor
      # recent_anchor = RecentAnchor.precise_anchor

      connection.query("SELECT id FROM `postings#{current_volume}` WHERE id <= #{recent_anchor} ORDER BY id DESC LIMIT 1").to_a.first.try(:[], 'id') || [(current_volume * Posting::VOLUME_SIZE-1), recent_anchor].min
    end

    def current_volume
      connection.query("SELECT volume from current_volume;").try(:first).try(:[], 'volume').try(:to_i)
    end

    def posting_exists_by_id?(id)
      volume = Posting2.volume_by_id(id)
      (id.to_i < RecentAnchor.anchor) && (volume >= FirstVolume.first_volume)
      #connection.query("select exists(select 1 from postings#{volume} where id = #{id});").to_a[0].values[0] == 1
    end

    def recent_postings_by_source
      connection.query("select source, max(timestamp) as timestamp from postings#{current_volume} group by source;").to_a
    end

    def volume_by_id(id)
      if id.blank? or id.to_i < 1
        0
      else
        (id.to_i - 1) / Posting::VOLUME_SIZE
      end
    end
  end
end
