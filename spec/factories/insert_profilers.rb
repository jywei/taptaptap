# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :insert_profiler do
    filter 1
    insert 1
    render 1
    overhead 1
    average_per_posting 1
    postings_count 1
    total_time 1
    postings "MyText"
  end
end
