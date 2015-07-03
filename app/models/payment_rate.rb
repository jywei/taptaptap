class PaymentRate < PaymentBase
  has_many :payment_group_rates, dependent: :destroy
  accepts_nested_attributes_for :payment_group_rates

  scope :in, -> { where("direction = 'in'") }
  scope :out, -> { where("direction = 'out'") }
  scope :search, -> { where("direction = 'search'") }

  class << self

    def get_groups_rates
      by_group = PaymentGroupRate.select(:category_group, :source, :rate).out
              .group(:category_group, :source).group_by(&:category_group)

      Hash[ by_group.map { |group, row| [group, Hash[ row.map { |e| [e[:source], e[:rate]] } ]] } ]
    end

    def get_categories_rates(category_group)
      rates = PaymentCategoryRate.select(:category, :source, :rate).out
              .where(category_group: category_group)
              .group(:category, :source)

      by_group = rates.group_by(&:category)

      Hash[ by_group.map { |group, row| [ group, Hash[ row.map { |e| [e[:source], e[:rate]] } ] ]} ]
    end

    # added random rates
    def fill
      available_groups = StatisticByTransferedData.get_available_groups

      ['in', 'out', 'search'].each do |direction|
        available_groups.each do |source, groups|
          rate = find_or_create_by(source: source, direction: direction)
          rate.update_attributes(all_groups: false, rate: rand(100).to_f / 10_000)

          if rate.payment_group_rates.blank?
            groups.each do |group|
              rate.payment_group_rates.create(category_group: group, source: rate.source, direction: rate.direction, rate: rand(100).to_f / 10_000)
            end

            rate.payment_group_rates.each do |group_rate|
                PostingConstants::CATEGORY_RELATIONS[group_rate.category_group].each do |category|
                  group_rate.payment_category_rates.create(
                    {
                      source: rate.source,
                      category_group: group_rate.category_group,
                      category: category,
                      direction: group_rate.direction,
                      rate: (rand(100).to_f / 10_000)
                    }
                  )
                end
              end
          end
        end
      end
    end
  end
end