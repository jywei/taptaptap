class ZipCode
  attr_accessor :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def self.create(attributes)
    ZipCode.new(attributes).save
  end

  def save
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    connection.query("INSERT INTO zipcodes (`zipcode`, `lat`, `long`) VALUES ('#{ connection.escape @attributes[:zipcode] }', '#{ @attributes[:lat] }', '#{ @attributes[:long] }');")

    connection.close

    self
  end

  def self.first
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    entity = connection.query("SELECT * FROM zipcodes limit 1").to_a.first

    connection.close

    entity
  end

  def self.batch_save(entities = [])
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    values = entities.map do |e|
      next unless e.is_a? Hash or (e.keys & [:zipcode, :lat, :long]).empty?
      "('#{ connection.escape e[:zipcode] }', '#{ e[:lat] }', '#{ e[:long] }')"
    end.join(', ')

    connection.query("INSERT INTO `zipcodes` (`zipcode`, `lat`, `long`) VALUES #{ values };")

    connection.close
  end

  def self.all
  connection = Mysql2::Client.new(
      {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
  )

  zipcodes = connection.query("SELECT * FROM zipcodes").to_a

  connection.close

  zipcodes
  end

  def self.find_by_zipcode(zipcode)
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    zipcode = connection.escape zipcode
    trimmed_zipcode = zipcode.gsub(/^0+(\d+)$/, '\\1')

    lat_and_long = connection.query("SELECT * FROM zipcodes WHERE zipcode='#{ zipcode }' OR zipcode='#{ trimmed_zipcode }' limit 1").to_a.first

    connection.close

    lat_and_long
  end
end
