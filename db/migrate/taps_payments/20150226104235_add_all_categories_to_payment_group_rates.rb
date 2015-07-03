class AddAllCategoriesToPaymentGroupRates < ActiveRecord::Migration
  def change
    add_column :payment_group_rates, :all_categories, :boolean, after: :rate
  end
end
