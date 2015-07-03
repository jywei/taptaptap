class CreatePaymentRates < ActiveRecord::Migration

  def change
    create_table :payment_rates do |t|
      t.string :source, limit: 5
      t.decimal :rate, precision: 8, scale: 6
      t.boolean :all_groups
      t.string :rates_by_groups
      t.string :type, :string, limit: 10
      t.timestamps
    end
  end
end
