class Location < ActiveRecord::Base
	LEVELS = %w(country state metro region county city locality zipcode)

	def fill_level!
		LEVELS.each do |level_variant|
			if self.send(level_variant) == self.code
				self.level = level_variant
				self.save!
				return
			end
		end
	end
end
