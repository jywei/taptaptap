class CreateDemandSourceRates < ActiveRecord::Migration
  def change
    create_table :demand_source_rates do |t|
      t.string :auth_token, limit: 32
      t.string :source, limit: 5
      t.decimal :rate, precision: 8, scale: 6
      t.string :direction, limit: 10
      t.boolean :all_groups
      t.decimal :max_sum
      t.timestamps
    end
  end
end
