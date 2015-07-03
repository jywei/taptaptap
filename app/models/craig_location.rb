class CraigLocation < ActiveRecord::Base
  serialize :location

  def self.collect_new
    connection =  Posting2.connection 
    volume = 811
    threshold = 100
    r1 = connection.query("select * from (select lat,`long`, count(lat) count from postings#{volume} where source = 'CRAIG' group by (lat)) a where count > #{threshold} order by count");
    r2 = connection.query("select cl.id, a.lat, a.`long`, count from (select lat,`long`, count(lat) count from postings#{volume} where source = 'CRAIG' group by (lat)) a inner join craig_locations cl on cl.lat = a.lat AND cl.`long` = a.`long` where count > #{threshold} order by count");
    add_to_db = r1.to_a;
    r2.each do |r|
      add_to_db.delete_if{|a| a['lat'] == r['lat'] && a['long'] == r['long'] }
    end;
    add_to_db.size

    Posting.table_name = "postings#{volume}"
    add_to_db.each do |a|
      p = Posting.where(lat: a['lat'], long: a['long']).first
      CraigLocation.create lat: p.lat, long: p.long, location: p.location
    end
  end

  def self.fill(filename = "#{Rails.root}/db/craig_locations.csv")
    ActiveRecord::Base.transaction do
      CSV.foreach(filename, headers: true) do |row|
        loc = CraigLocation.new

        loc.location = JSON.parse(row.to_hash['_location_object']).first.except('success').with_indifferent_access
        loc.lat = row.to_hash['_lat']
        loc.long = row.to_hash['_long']

        unless loc.location.keys.include?('error')
          puts "save location with lat #{loc.lat} and long #{loc.long}"
          loc.save
        end
      end
    end
  end

  def self.fill_in_db
    CraigLocation.all.each do |cl|
      location = GeoApi.batch_locations([{'latitude' => cl['lat'], 'longitude' => cl['long']}])[0]
      location.delete('success')

      if location.delete('error')
        p "error on id #{cl.id}"
      else
        p "writing id #{cl.id}"

        if cl.location == location
          p "location is same"
        else
          p "current location: #{cl.location}"
          p "new location: #{location}"

          cl.location = location
          cl.save
        end
      end
    end
  end
end
