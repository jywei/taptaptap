class GeoBatch
  def self.upd_cl_locations
    client = Mysql2::Client.new({host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter))
    count = client.query("select count(*) from CL_Locations").first.first[1]
    num_same = 0
    num_upd = 0
    num_multi = 0
    count.times do |i|
      begin
        q = %Q(select * from CL_Locations where id = #{i + 1})
        fields = client.query(q).first
        loc = fields['source_location'].to_s + ', ' + fields['st'].to_s + ', ' + fields['posting_country'].to_s
        geo = Geocoder.search loc
        if geo.size == 1
          lat = geo.first.data['geometry']['location']['lat'].round(5)
          long = geo.first.data['geometry']['location']['lng'].round(5)
          if lat == fields['lat'] && long == fields['long']
            p "coords are same for id  #{i + 1}"
            num_same += 1
          else
            p "coords differ for id #{i + 1}"
            q = %Q(UPDATE CL_Locations set lat = #{lat}, `long` = #{long} where id = #{i + 1};)
            client.query(q)
            num_upd += 1
          end
        else
          p "id #{i + 1} has #{geo.size} results from geocoder"
        end
        sleep 0.5
      rescue Exception => e
        p e.inspect
        p e.backtrace
      end
    end
    p "new coords: #{num_upd}"
    p "same coords: #{num_same}"
    p "multi coords: #{num_multi}"
  end

  def self.anchor_updater
    while true do
      anchor = RecentAnchor.first
      id = anchor.anchor
      volume = id / 1_000_000
      Posting.table_name = "postings#{volume}"

      ids = [Posting.where('geolocation_status=1').minimum('id'), Posting.where('geolocation_status=2').minimum('id')].compact
      id = Posting.where('geolocation_status=1').minimum('id')
      if id
      # if r = Posting.select('id').where("(geolocation_status = #{Posting::GeoStatus::TO_LOCATE} OR geolocation_status = #{Posting::GeoStatus::LOCATING}) AND id > #{id}").order("id ASC").limit(1).first
        #id = r.id - 1
        #id = ids.min

#        p "#{Time.now.to_i}: query #{Posting.select('id').where("(geolocation_status = #{Posting::GeoStatus::TO_LOCATE} OR geolocation_status = #{Posting::GeoStatus::LOCATING}) AND id > #{id}").order("id ASC").limit(1).to_sql}"
        p id
        p id - anchor.anchor

        anchor.update_attribute(:anchor, id) unless anchor.anchor_freeze
      else
        if Posting.count >= 1_000_000
          last_id = (volume + 1) * 1_000_000
          p last_id
          anchor.update_attribute(:anchor, last_id) unless anchor.anchor_freeze
        else
          p "old anchor"
        end
      end

      begin
        if !(ps = PostingStat.not_anchored.where("posting_id < #{anchor.anchor}")).blank?
          ps.update_all("anchored_at = '#{Time.now.to_s(:db)}'")
        end
      rescue Exception => e
        SULO3.error "anchor error:"
        SULO3.error e.message
        SULO3.error e.backtrace.join("\n")
        TapsException.track(message: e.message, notify: true, details: e.backtrace.join(', '), module_name: 'anchor runner')
      end

      sleep 1
    end
  end

  def self.geo_locate_cl(num, _count = 4)
    #anchor = RecentAnchor.first
    #id = anchor.present? ? anchor.anchor : Posting2.default_anchor
    #volume = id / 1_000_000



    #Posting2.connection.query "update postings#{volume} set geolocation_status = 4 where id = #{first_id}"    


    while true do
      additional_condition = nil
      #additional_condition = if Time.now - time > 3.minutes
      #  time=Time.now
      #additional_condition =   "OR geolocation_status = #{Posting::GeoStatus::LOCATING}"
      #else
      #  nil
      #end

      id_condition = ""
      if num <= _count
        id_condition << "AND id % #{_count} = #{num - 1}"
      end

      anchor = RecentAnchor.first
      id = anchor.present? ? anchor.anchor : Posting2.default_anchor
      p anchor
      volume = id / 1_000_000
      if num
        volume += 1 if num > _count
        volume += 1 if num > (_count + 2)
        volume += 1 if num > (_count + 3)
        volume += 1 if num > (_count + 5)
      end
      t = Time.now
      p "========================================="
      p "volume #{volume}"
      Posting.table_name = "postings#{volume}"

      bunch = []
      p "Posting.table_name #{Posting.table_name}"
      #last_id = Posting.select("id").last.id
      #p "last_id #{last_id}"

      count = 500
      count = 750 if Posting2.current_volume != volume

      p "query #{Posting.select('id, source, category, category_group,`long`, lat, geolocation_status').where("geolocation_status = #{Posting::GeoStatus::TO_LOCATE} #{additional_condition}  #{id_condition}").order('id asc').limit(count).to_sql}"
      postings = Posting.select('id, source, category, category_group,`long`, lat, geolocation_status').where("geolocation_status = #{Posting::GeoStatus::TO_LOCATE} #{additional_condition} #{id_condition}").order('id asc').limit(count)

      #p "query #{Posting.select('id,`long`,lat').where("id > #{id} AND (source='CRAIG' OR source='EBAYM') AND country = '' AND state = '' AND metro = '' AND region = '' AND county = ''").order('id asc').limit(1000).to_sql}"
      #postings = Posting.select('id,`long`,lat').where("id > #{id} AND (source='CRAIG' OR source='EBAYM') AND country = '' AND state = '' AND metro = '' AND region = '' AND county = ''").order('id asc').limit(1000)
      #p "postings size #{postings.size}"
      if postings.to_a.empty?
        p "postings empty"
        #id = last_id
      else
        #p "postings not empty"
        #p "postings: #{postings.to_a.inspect}"
        #p "postings empty? #{postings.empty?}"
        #p = postings.first
        #p "first posting: #{p.id}"
#        id4 = p.id
 #       p 'id taken'
  #      while p && p.geolocation_status == Posting::GeoStatus::ON_SELECT_TO_LOCATE
   #       p "#{id4}: Posting::GeoStatus::ON_SELECT_TO_LOCATE"
    #      postings = Posting.select('id, source, category, category_group,`long`, lat, geolocation_status').where("geolocation_status = #{Posting::GeoStatus::TO_LOCATE} #{additional_condition} OR geolocation_status = #{Posting::GeoStatus::ON_SELECT_TO_LOCATE}").order('id asc').limit(count)
     #     p = postings.first
      #  end

        #if p
          first_id = postings.first.id
          p "first posting id: #{first_id}, geo status: #{postings.first.geolocation_status}"
          #Posting2.connection.query "update postings#{volume} set geolocation_status = 4 where id = #{first_id}"
          #p.update_attribute(:geolocation_status, Posting::GeoStatus::ON_SELECT_TO_LOCATE)
          begin
            p "last posting id: #{postings.last.id}"
            #id = postings.last.id

            ids = postings.collect(&:id)
            p "first id to update to status 2: #{ids.first}"
            #p "id4 is included: #{ids.include? id4}"
            #upd_time = Time.now
            #Posting.connection.execute("UPDATE postings#{volume} SET geolocation_status = #{Posting::GeoStatus::LOCATING} WHERE id IN (#{ids.join(',')});")
            # RecentAnchor.update_precise_anchor(ids.map(&:to_i).max)
            #upd_time = Time.now - upd_time
            #p "upd_time: #{upd_time}"

            postings.each do |p|
              #p.update_attribute :geolocation_status, Posting::GeoStatus::LOCATING
              bunch << {'id' => p.id, 'source' => p.source, 'category' => p.category, 'category_group' => p.category_group, 'lat' => p.lat, 'long'=> p.long} #.stringify_keys
            end
            #if last_id - postings.last.id < 1000
            geotime = Time.now
            GeoLocations::BatchFetchViaApiService.new(bunch).perform
            geotime = Time.now - geotime
            p "geotime: #{geotime} s"
            #else
            # BG for faster processing
            #  Resque.enqueue(BatchGeoApiWorker, bunch)
            #end
            p postings.size
          rescue Exception => e
            geo_exc_logger = Logger.new("/home/#{Rails.env.production? ? 'posting' : 'staging'}/posting/shared/log/geo_exceptions.log")
            geo_exc_logger.error(e.inspect)
            geo_exc_logger.error(e.backtrace)
            p e.message

            TapsException.track(message: e.message, notify: true, details: e.backtrace.join(', '), module_name: 'geo runner')
          end
        #end
      end

      #if Posting.select('geolocation_status').where("id = #{postings.last.id}").first.geolocation_status == Posting::GeoStatus::LOCATING
      #  p "POSTINGS NOT UPDATED!!!"
      #end

      time_spent = Time.now - t
      p "#{time_spent} seconds"

      # after party
      if postings.empty?
        p "sleep 1 second"
        sleep(1)
      end

      if File.exists?("log/kill_runner#{num}.txt")
        p "Removing kill_runner#{num}.txt file and ending cycle"
        %x[rm -f log/kill_runner#{num}.txt]
        break
      end
    end
  end
end
