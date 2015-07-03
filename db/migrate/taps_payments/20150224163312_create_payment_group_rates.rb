class CreatePaymentGroupRates < ActiveRecord::Migration
  def change
    create_table :payment_group_rates do |t|
      t.references :payment_rate
      t.string :source, limit: 5
      t.string :category_group, limit: 4
      t.decimal :rate, precision: 8, scale: 6
      t.string :direction, limit: 10

      t.timestamps
    end
  end
end
