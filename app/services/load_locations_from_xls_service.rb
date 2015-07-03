require 'csv'

class LoadLocationsFromXlsService
  attr_accessor :spreadsheet, :header, :path

  def initialize(path)
    @path = path
    @spreadsheet = Roo::Excel.new(path)
  end

  def perform
    build_data
  end

  def update_location_object
    coordinates = a = []

    CSV.open("system_files/craig_locations.csv", "wb") do |csv|
      csv << spreadsheet.row(1)
      
      2.upto(spreadsheet.last_row) do |line|
        coordinates = ['latitude' => spreadsheet.cell(line, "K"), 'longitude' => spreadsheet.cell(line, "J")]
        locations = GeoApi.batch_locations(coordinates)

        a = spreadsheet.row(line).map do |el| 
          if (el.is_a? Float) && (el - el.to_i == 0)
            el.to_i
          else
            el
          end
        end

        if locations[0].has_key?("error")
          puts "error in #{line}"
          a[19] = {}
        else
          a[19] = locations[0].reject!{ |k| k == "success" }
        end

        csv << a
      end
    end
  end

  private

  def build_data
    result = {}
    self.header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      r = row(i)

      next if r['_long'].zero? && r['_lat'].zero?

      key = "#{r['_long']}__#{r['_lat']}"
      location_data = ActiveSupport::JSON.decode(r['_location_object']).first

      result[key] = [
        location_data['country'],
        location_data['state'],
        location_data['metro']
      ]
    end

    result
  end

  def row(i)
    Hash[[header, spreadsheet.row(i)].transpose]
  end
end