class DeleteAuthTokenFromDemandGroupRates < ActiveRecord::Migration
  def change
    remove_column :demand_group_rates, :auth_token
    remove_column :demand_group_rates, :source

    add_reference :demand_group_rates, :demand_source_rate, after: :id, index: true
  end
end
