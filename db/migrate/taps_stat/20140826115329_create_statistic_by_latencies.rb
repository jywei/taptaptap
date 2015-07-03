class CreateStatisticByLatencies < ActiveRecord::Migration
  def change
    create_table :statistic_by_latencies do |t|
      t.integer :posting_id
      t.column :source, 'char(5)'
      t.integer :latency
      t.datetime :posting_created_at

      t.timestamps
    end
  end
end
