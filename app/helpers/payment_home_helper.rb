module PaymentHomeHelper
  extend ActionView::Helpers::NumberHelper

  def self.format_contracts(contracts)
    contracts.map do |contract|
      contract = contract.attributes
      contract['cost'] = number_to_currency (contract['cost'] || 0)

      contract
    end
  end

  def self.format_monthly_stats(stats)
    stats[:contracts] = number_with_delimiter (stats[:contracts_count] || 0)
    stats[:customer_payment] = number_to_currency (stats[:customer_payment] || 0)
    stats[:sender_revenue] = number_to_currency (stats[:sender_revenue] || 0)
    stats
  end
end
