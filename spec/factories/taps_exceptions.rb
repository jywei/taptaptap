# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :taps_exception do
    number "MyString"
    message "MyText"
    notify false
  end
end
