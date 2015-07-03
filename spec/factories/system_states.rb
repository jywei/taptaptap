# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :system_state do
    geo_runners 1
    mysql_processes 1
    unicorn_workers 1
    anchor_runners 1
    bkpge_runners 1
  end
end
