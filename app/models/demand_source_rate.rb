class DemandSourceRate < PaymentBase
  has_many :demand_group_rates, dependent: :destroy
  accepts_nested_attributes_for :demand_group_rates

  scope :last_month, -> { where(created_at: (Time.now - 1.month).at_beginning_of_month..Time.now.at_beginning_of_month) }
  scope :this_month, -> { where(created_at: Time.now.at_beginning_of_month..Time.now ) }


  def self.fill(prev_count = 12, this_count = 15)
    DemandSourceRate.delete_all
    current_month = Time.now
    prev_month = current_month - 1.month
    available_groups = StatisticByTransferedData.get_available_groups


    [prev_month, current_month].each do |date|
      if prev_month == date
        n = prev_count
        end_date = date.at_end_of_month
      else
        n = this_count
        end_date = date
      end

      (1..n).each do |_n|

        auth_token = (('a'..'z').to_a + (0..9).to_a).shuffle.take(32).join

        available_groups.keys.shuffle.take(rand(available_groups.keys.size)).each do |source|
          DemandSourceRate.create(
            {
              auth_token: auth_token,
              source: source,
              rate: (rand * 0.01).round(4),
              all_groups: true,
              max_sum: rand(1000),
              direction: :out,
              created_at: date,
              updated_at: date
            }
          )

          (date.at_beginning_of_month.to_date..end_date.to_date).each  do |test_date|
            sample_date = date.at_beginning_of_month
            available_groups[source].each do |group|
              StatisticByTransferedData.create(
                {
                  source: source,
                  category_group: group,
                  auth_token: auth_token,
                  for_date: sample_date.strftime("%Y-%m-%d"),
                  ip: '127.0.0.1',
                  amount: rand(1_000),
                  data_size: rand(1_000_000),
                  direction: :out,
                  created_at:test_date,
                  updated_at: test_date
                }
              )
            end
            sample_date += 1.day
          end
        end
      end
    end
    p "creted 9 samples for #{prev_month} and 15 samples for #{current_month}"
  end

end