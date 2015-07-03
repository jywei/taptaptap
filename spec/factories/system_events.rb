# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :system_event do
    event "MyString"
    description "MyText"
  end
end
