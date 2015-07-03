# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :raw_posting do
    raw "MyText"
    posting nil
  end
end
