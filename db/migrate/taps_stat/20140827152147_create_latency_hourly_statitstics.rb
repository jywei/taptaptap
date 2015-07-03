class CreateLatencyHourlyStatitstics < ActiveRecord::Migration
  def change
    create_table :latency_hourly_statistics do |t|
      t.string :source
      t.float :latency
      t.datetime :for_hour

      t.timestamps
    end

    add_index :latency_hourly_statistics, [:source, :for_hour], unique: true, name: 'index_on_source_latency'
  end
end
