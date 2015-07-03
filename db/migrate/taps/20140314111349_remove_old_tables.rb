class RemoveOldTables < ActiveRecord::Migration
  def change
    drop_table :posting_deletes
    drop_table :posting_examples
    drop_table :posting_monitors
    drop_table :three_scale_stats
  end
end
