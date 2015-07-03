class RenameTypeColumnInPaymentRates < ActiveRecord::Migration
  def up
    rename_column :payment_rates, :type, :direction
  end

  def down
    rename_column :payment_rates, :direction, :type
  end
end
