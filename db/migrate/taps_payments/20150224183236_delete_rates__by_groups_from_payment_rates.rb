class DeleteRatesByGroupsFromPaymentRates < ActiveRecord::Migration
  def change
    remove_column :payment_rates, :rates_by_groups
  end
end
