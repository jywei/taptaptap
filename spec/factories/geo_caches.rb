# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :geo_cach, :class => 'GeoCache' do
    formatted_address "MyString"
  end
end
