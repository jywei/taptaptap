require 'csv'
class ClLocation < ActiveRecord::Base
	self.table_name = "CL_Locations"

	def self.create_csv
		data = all.map{|item| item.attributes}
		CSV.open("tmp/cl_locations.csv", "wb") do |csv|
  		csv << data.first.keys # adds the attributes name on the first line
  		data.each do |hash|
    		csv << hash.values
  		end
		end
		#data
	end	
end