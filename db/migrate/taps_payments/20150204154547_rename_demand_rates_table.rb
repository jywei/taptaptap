class RenameDemandRatesTable < ActiveRecord::Migration
  def change
    rename_table :demand_rates, :demand_group_rates
  end
end
