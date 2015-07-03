# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :statistic_by_heartbeat do
    criteria "MyString"
    for_date "2014-09-03"
    count 1
  end
end
