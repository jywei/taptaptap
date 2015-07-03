class CreatePollTimeouts < ActiveRecord::Migration
  def change
    create_table :poll_timeouts do |t|
      t.text :unicorn_stats
      t.text :db_stats
      t.text :message

      t.timestamps
    end
  end
end
