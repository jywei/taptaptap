class CreateDemandRates < ActiveRecord::Migration
  def change
    create_table :demand_rates do |t|
      t.string :auth_token, limit: 32
      t.string :source, limit: 5
      t.string :group, limit: 4
      t.decimal :rate, precision: 8, scale: 6
      t.string :direction, limit: 10

      t.timestamps
    end
  end
end
