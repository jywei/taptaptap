namespace :locations do
  desc "fetch all locations"
  task :init_all => :environment do
    puts 'delete all locations'
    Location.delete_all
    puts 'fetch all locations'
    levels = %w(country state metro region county city locality zipcode)
    levels.each do |level|
      Rake::Task["locations:fetch_#{level.pluralize}"].execute(level)
    end
  end

  desc "fetch countries"
  task :fetch_countries => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "fetch states"
  task :fetch_states => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "fetch metro"
  task :fetch_metros => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "fetch region"
  task :fetch_regions => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "fetch county"
  task :fetch_counties => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "fetch city"
  task :fetch_cities => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "fetch locality"
  task :fetch_localities => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "fetch zipcode"
  task :fetch_zipcodes => [:environment, :level] do |t, level|
    fetch_and_store_locations_by_level(level)
  end

  desc "complete all locations"
  task :complete_all => :environment do
    puts 'complete all locations'

    levels_source = %w(metro region county city locality zipcode)
    levels_base = %w(country state metro region county city locality)
    Location.transaction do
      levels_base.each do |level_base, index|
        puts '--------------------------------------'
        puts '--------------------------------------'
        puts '--------------------------------------'
        puts "fill for #{level_base}"
        Location.where("#{level_base} IS NOT NULL").each do |location|
          puts '--------------------------------------'
          puts '--------------------------------------'
          puts "fill for #{location.code}"
          levels_source.each do |level_source|
            puts "#{REFERENCE_LOCATIONS_URL}?auth_token=#{TAPS_AUTH_TOKEN}&level=#{level_source}&#{level_base}=#{location.code}"
            locations_json = RestClient.get "#{REFERENCE_LOCATIONS_URL}?auth_token=#{TAPS_AUTH_TOKEN}&level=#{level_source}&#{level_base}=#{location.code}" rescue nil
            next if locations_json.blank?
            locations = JSON.parse(locations_json)['locations']
            puts locations
            next if locations.blank?
            location_codes = locations.map {|loc| loc['code']}
            Location.update_all({level_base => location.code}, {level_source => location_codes})
          end
        end
      end
    end
  end

  desc "fill the level"
  task :fill_level => [:environment] do
    Location.transaction do
      Location.all.each_with_index do |location, index|
        puts "fill the #{index+1}s" if index % 100 == 0
        location.fill_level!
      end
    end
  end
end

def fetch_and_store_locations_by_level(level)
  puts '-------------------------------------------------'
  puts "fecth #{level.pluralize}"
  locations_json = RestClient.get "#{REFERENCE_LOCATIONS_URL}?auth_token=#{TAPS_AUTH_TOKEN}&level=#{level}"
  locations = JSON.parse(locations_json)['locations']
  Location.transaction do
    locations.each do |location|
      puts "create location #{location['short_name']}"
      location[level]=location['code']
      Location.create! location
    end
  end
end