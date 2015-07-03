FactoryGirl.define do
  factory :system_data do

  end

  factory :sys_data_partitioning, parent: :system_data do
    name :partitions_start_date
  end
end
