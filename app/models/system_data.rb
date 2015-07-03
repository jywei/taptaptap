require 'csv'

class SystemData < ActiveRecord::Base
  @timestamp = Time.now.to_i

  def self.fill_zips
    zipcodes = []

    CSV.foreach("#{Rails.root}/db/zipcodes.csv", headers: :first_row) do |row|
      zipcodes << { zipcode: row[0], lat: row[1], long: row[2] }
    end

    ZipCode.batch_save(zipcodes)
  end

  def self.fill_craig_locations
    CraigLocation.fill
  end

  def self.fill_craig_locations_in_db
    CraigLocation.fill_in_db
  end

  def self.for_test_deletes(n, attrs)
    source = %w(EBAYM CRAIG REMLS)

    result = []
    n.times do |i|
      a = {
          source: 'CRAIG',
          #status: {deleted: 'true'},
          deleted: 'true',
          external_id: rand(1_000_000)
      }
      result << a.merge(attrs)
    end
    {'postings' => result, 'auth_token' => '0e6b9ead7eca1caee8dfed7dbdf88447'}
  end

  def self.for_test(n = 90, attrs = {})
    subcats = Posting::CRAIG_STATUSES_BY_CAT.keys

    annotations = %w(test_annotation sample_annotation new_annotation )
    carmakers = ["Acura", "Alfa Romeo", "AMC", "Aston Martin", "Audi", "Bentley", "BMW"]

    source = PostingConstants::SOURCES
    category_group = PostingConstants::CATEGORY_GROUPS
    category = PostingConstants::CATEGORIES
    country = %w(loc1 loc2 loc3)
    state = %w(USA-AL AR AZ CA CO CT DC DE FL GA IA)
    metro = PostingConstants::MCR_CODES #%w(loc1 loc2 loc3)
    region = %w(loc1 loc2 loc3)
    county = %w(loc1 loc2 loc3)
    city = %w(loc1 loc2 loc3)
    locality = %w(loc1 loc2 loc3)
    zipcode = %w(55348  55349 55344 74701 73546 74702)
    status = PostingConstants::STATUSES
    posting_state = PostingConstants::STATES

    #TODO: move this hash into YAML file
    a = {
        'category' => category.sample,
        'account_id' => '3',
        'location' => {
            'lat' => '32.60986',
            'long' => '-85.48078'
        },
        'external_id' => '122233',
        'external_url' => 'http://www.hemmings.com/classifieds/dealer/rolls_royce/phantom_i/1409477.html?refer=rss',
        'heading' => '1928 Rolls-Royce Phantom I',
        'body' => 'some body',
        'html' => 'some html',
        'expires' => 1375219975,
        'language' => 'EN',
        'price' => 100,
        'currency' => 'USD',
        'images' => [
            {'full' => 'http://assets.hemmings.com/uimage/10601449-425-0.jpg3'}
        ],
        'annotations' => {
            'Make' => 'Rolls Royce',
            'Model' => 'Phantom I',
            'Year' => '1928',
            'source_subcat' => 'bfa',
            'source_account' => "test account",
            'beds' => 2,
            'formatted_address' => 'some address'
        },
        'status' => 'for_sale',
        'state' => 'available',
        'deleted' => false,
        'immortal' => 'false',
        'flagged_status' => '0',
        'origin_ip_address' => '127.0.0.1',
        'transit_ip_address' => '111.111.111.111'
    }

    result = []

    n.times do |i|
      sample_subcat = subcats.sample
      a['timestamp'] = (Time.now - rand(60).minutes).to_i
      a['annotations']['source_subcat'] = sample_subcat
      a['annotations']['make'] = carmakers.sample

      rand(annotations.size).times do
        a['annotations'][annotations.sample] = "annotation_value_#{ rand(10) + 1 }"
      end

      a['source'] = source.rand
      a['external_id'] = 1000 + i
      a['category'] = PostingConstants::MCR_CATEGORIES.rand #category.rand
      a['category_group'] = PostingConstants::CATEGORY_RELATIONS_REVERSE[a['category']]
      a['location'] = a['location'].clone
      a['location']['country'] = country.rand
      a['location']['state'] = ZipsTracker.states.keys.rand
      a['location']['metro'] = metro.rand
      a['location']['region'] = region.rand
      a['location']['county'] = county.rand
      a['location']['city'] = city.rand
      a['location']['locality'] = locality.rand
      a['location']['zipcode'] = ZipsTracker.state(a['location']['state']).rand #zipcode.rand
      a['status'] = status.rand
      a['state'] = posting_state.rand

      result.push a.merge(attrs)
    end

    { 'postings' => result, 'auth_token' => '0e6b9ead7eca1caee8dfed7dbdf88447' }
  end

  def self.for_converter_test(n, attr)
    data = for_test(n, attr)
    postings = data['postings']

    postings.each { |item| item.delete('category_group') }

    postings
  end

  def self.fill(n = 90, attrs = {}, url = 'localhost:3000')
    RestClient.post url, for_test(n, attrs).to_json, :content_type => :json, :accept => :json
  end

  def self.fill_deletes(n = 10, attrs = {}, url = 'staging-posting.3taps.com')
    RestClient.post url, for_test_deletes(n, attrs).to_json, :content_type => :json, :accept => :json
  end

  def self.full_fill(n=90, k=10)
    k.times do |iter|
      puts "#{iter+1} of #{k}"
      fill(n)
    end
  end

  # testing method
  def self.anchor(a)
    RestClient.get "localhost:3000/anchor?timestamp=#{a}&auth_token=0e6b9ead7eca1caee8dfed7dbdf88447"
  end

  def self.create_tables(password, first, last, suffix = nil)
    return 'nope' unless password == 'taptaptap'
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    first.to_i.upto(last) do |i|
      connection.query(create_table_script(i, suffix))
    end
  end

  def self.copy_to_temporary(first, last)
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    first.to_i.upto(last) do |i|
      puts "insert into postings#{i}_temporary select * except id from postings#{i}"
      connection.query("INSERT INTO postings#{i}_temporary (`source`,`category`,`external_id`,`external_url`,`heading`,`body`,`html`,`expires`,`language`,`price`,`currency`,`images`,`annotations`,`status`,`flagged`,`deleted`,`immortal`,`timestamp`,`created_at`,`updated_at`,`category_group`,`country`,`state`,`metro`,`region`,`county`,`city`,`locality`,`zipcode`,`lat`,`long`,`accuracy`,`min_lat`,`max_lat`,`min_long`,`max_long`,`account_id`,`posting_state`,`flagged_status`,`origin_ip_address`,`transit_ip_address`,`geolocation_status`) SELECT `source`,`category`,`external_id`,`external_url`,`heading`,`body`,`html`,`expires`,`language`,`price`,`currency`,`images`,`annotations`,`status`,`flagged`,`deleted`,`immortal`,`timestamp`,`created_at`,`updated_at`,`category_group`,`country`,`state`,`metro`,`region`,`county`,`city`,`locality`,`zipcode`,`lat`,`long`,`accuracy`,`min_lat`,`max_lat`,`min_long`,`max_long`,`account_id`,`posting_state`,`flagged_status`,`origin_ip_address`,`transit_ip_address`,`geolocation_status` FROM postings#{i};")
    end
  end

  def self.rename_tables(first, last, current_suffix, desired_suffix)
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    first.to_i.upto(last) do |i|
      puts "RENAME TABLE postings#{i}#{current_suffix} TO postings#{i}#{desired_suffix}"
      connection.query("RENAME TABLE postings#{i}#{current_suffix} TO postings#{i}#{desired_suffix}")
    end
  end

  def self.create_table_script(volume, suffix = nil)
    %Q(
      CREATE TABLE `postings#{volume}#{suffix}` (
        `id` bigint unsigned NOT NULL AUTO_INCREMENT,
        `source` varchar(5) DEFAULT NULL,
        `category` varchar(4) DEFAULT NULL,
        `external_id` varchar(20) DEFAULT NULL,
        `external_url` varchar(385) DEFAULT NULL,
        `heading` varchar(155) DEFAULT NULL,
        `body` text,
        `html` text,
        `expires` int(11) DEFAULT NULL,
        `language` varchar(2) DEFAULT NULL,
        `price` float DEFAULT NULL,
        `currency` varchar(3) DEFAULT NULL,
        `images` text,
        `annotations` text,
        `status` varchar(10) DEFAULT NULL,
        `flagged` tinyint(1) DEFAULT NULL,
        `deleted` tinyint(1) DEFAULT '0',
        `immortal` tinyint(1) DEFAULT '0',
        `timestamp` int(11) DEFAULT NULL,
        `timestamp_deleted` int(11) DEFAULT NULL,
        `created_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
        `updated_at` datetime DEFAULT NULL,
        `category_group` varchar(4) DEFAULT NULL,
        `country` varchar(3) DEFAULT NULL,
        `state` varchar(10) DEFAULT NULL,
        `metro` varchar(7) DEFAULT NULL,
        `region` varchar(11) DEFAULT NULL,
        `county` varchar(10) DEFAULT NULL,
        `city` varchar(12) DEFAULT NULL,
        `locality` varchar(12) DEFAULT NULL,
        `zipcode` varchar(9) DEFAULT NULL,
        `lat` decimal(9,6) DEFAULT NULL,
        `long` decimal(9,6) DEFAULT NULL,
        `accuracy` int(11) DEFAULT NULL,
        `min_lat` float DEFAULT NULL,
        `max_lat` float DEFAULT NULL,
        `min_long` float DEFAULT NULL,
        `max_long` float DEFAULT NULL,
        `account_id` varchar(10) DEFAULT NULL,
        `posting_state` varchar(9) DEFAULT NULL,
        `flagged_status` int(11) DEFAULT '0',
        `origin_ip_address` varchar(15) DEFAULT NULL,
        `transit_ip_address` varchar(15) DEFAULT NULL,
        `proxy_ip_address` varchar(15) DEFAULT NULL,
        `geolocation_status` tinyint(4) DEFAULT '0',
        `fields_quality` tinyint(4) DEFAULT NULL,
        `annotations_quality` tinyint(4) DEFAULT NULL,
        `formatted_address` varchar(255) DEFAULT NULL,
        `is_update` boolean DEFAULT FALSE,
        PRIMARY KEY (`id`),
        KEY `index_postings#{volume}_on_category` (`category`) USING BTREE,
        KEY `index_postings#{volume}_on_created_at` (`created_at`) USING BTREE,
        KEY `index_postings#{volume}_on_category_group` (`category_group`) USING BTREE,
        KEY `index_postings#{volume}_on_city` (`city`) USING BTREE,
        KEY `index_postings#{volume}_on_country` (`country`) USING BTREE,
        KEY `index_postings#{volume}_on_county` (`county`) USING BTREE,
        KEY `index_postings#{volume}_on_deleted` (`deleted`),
        KEY `index_postings#{volume}_on_external_id_and_source` (`external_id`,`source`) USING BTREE,
        KEY `index_postings#{volume}_on_locality` (`locality`) USING BTREE,
        KEY `index_postings#{volume}_on_metro` (`metro`) USING BTREE,
        KEY `index_postings#{volume}_on_region` (`region`) USING BTREE,
        KEY `index_postings#{volume}_on_source` (`source`) USING BTREE,
        KEY `index_postings#{volume}_on_state` (`state`) USING BTREE,
        KEY `index_postings#{volume}_on_status` (`status`) USING BTREE,
        KEY `index_postings#{volume}_on_zipcode` (`zipcode`) USING BTREE,
        KEY `index_postings#{volume}_on_timestamp` (`timestamp`),
        KEY `index_postings#{volume}_on_posting_state` (`posting_state`),
        KEY `index_postings#{volume}_on_geolocation_status` (`geolocation_status`),
        KEY `index_postings#{volume}_on_source_and_category` (`source`,`category`),
        KEY `index_postings#{volume}_on_source_and_created_at` (`source`,`created_at`),
        KEY `index_postings_on_source_and_geolocation_status_and_created_at` (`source`,`geolocation_status`,`created_at`),
        KEY `index_postings_on_source_and_geo_and_category_and_created_at` (`source`,`geolocation_status`,`category`,`created_at`),
        KEY `index_postings#{volume}_on_source_and_category_group` (`source`,`category_group`),
        KEY `index_postings#{volume}_on_source_and_category_and_id` (`source`,`category`,`country`,`id`),
        KEY `index_postings#{volume}_on_source_and_category_and_country` (`source`,`category`,`country`),
        KEY `index_postings#{volume}_on_source_and_category_and_state` (`source`,`category`,`state`),
        KEY `index_postings#{volume}_on_source_and_category_and_region` (`source`,`category`,`region`),
        KEY `index_postings#{volume}_on_source_and_category_and_metro` (`source`,`category`,`metro`),
        KEY `index_postings#{volume}_on_source_and_category_and_city` (`source`,`category`,`city`),
        KEY `index_postings#{volume}_on_source_and_category_and_county` (`source`,`category`,`county`),
        KEY `index_postings#{volume}_on_source_and_category_and_locality` (`source`,`category`,`locality`),
        KEY `index_postings#{volume}_on_source_and_category_and_zipcode` (`source`,`category`,`zipcode`),
        KEY `index_postings#{volume}_on_source_and_status` (`source`,`status`),
        KEY `index_postings#{volume}_on_source_and_category_group_and_id` (`source`, `category_group`, `id`),
        KEY `index_postings#{volume}_on_category_and_source_and_state` (`category`, `source`, `state`),
        KEY `index_postings#{volume}_on_category_and_source_and_posting_state` (`category`, `source`, `posting_state`),
        KEY `index_postings#{volume}_on_id_status_category_group_category` (`id`, `status`, `category_group`, `category`),
        KEY `index_postings#{volume}_on_source_id_category_group` (`source`, `id`, `category_group`),
        KEY `index_postings#{volume}_on_fields_quality` (`fields_quality`),
        KEY `index_postings#{volume}_on_annotations_quality` (`annotations_quality`),
        KEY `index_postings#{volume}_on_category_group_metro_id` (`category_group`,`metro`,`id`),
        KEY `index_postings#{volume}_on_category_country_id_source` (`category`, `country`, `id`, `source`),
        KEY `index_postings#{volume}_on_category_source_id` (`category`, `source`, `id`),
        KEY `index_on_source_category_group_country_state_metro_city_id` (`source`,`category_group`,`country`,`state`,`metro`,`city`,`id`),
        KEY `index_postings#{volume}_on_geolocation_status_and_id` (`geolocation_status`,`id`),
        KEY `index_postings#{volume}_on_id_state_category` (`id`,`state`,`category`)
      ) ENGINE=MyISAM AUTO_INCREMENT=#{volume.to_i * Posting::VOLUME_SIZE+ 1} DEFAULT CHARSET=latin1;
    )
  end

  def self.add_polling_index_script(keys)
    columns = keys.map { |k| "`#{k}`" }.join(',')
    query = ''

    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      index_name = "on_#{ keys.join('_and_') }"

      query += %Q(
        ALTER TABLE `postings#{ volume }` ADD INDEX `#{ index_name }` (#{ columns })
      )
    end

    query
  end
end
