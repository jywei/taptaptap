class CreateStatisticByHeartbeats < ActiveRecord::Migration
  def change
    create_table :statistic_by_heartbeats do |t|
      t.datetime :for_timestamp
      t.string :criteria
      t.integer :count

      t.timestamps
    end
  end
end
