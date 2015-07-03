FactoryGirl.define do
  factory :location do
  	code 'ZIPCODE-CODE'
		full_name 'location full name'
		short_name 'location short name'
  	parent_id nil
		country 'COUNTRY-CODE'
		state 'STATE-CODE'
		metro 'METRO-CODE'
		region 'REGION-CODE'
		county 'COUNTY-CODE'
		city 'CITY-CODE'
		locality 'LOCALITY-CODE'
		zipcode 'ZIPCODE-CODE'
		bounds_max_lat 123
		bounds_max_long 123
		bounds_min_lat 123
		bounds_min_long 123
  end
end
