class CreateStatisticByUpdates < ActiveRecord::Migration
  def change
    create_table :statistic_by_updates do |t|
      t.date :for_date
      t.string :source
      t.string :category
      t.integer :count
    end
  end
end
