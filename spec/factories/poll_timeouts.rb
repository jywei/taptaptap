# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :poll_timeout do
    unicorn_status "MyText"
    db_status "MyText"
  end
end
