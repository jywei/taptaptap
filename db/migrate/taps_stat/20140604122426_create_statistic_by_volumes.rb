class CreateStatisticByVolumes < ActiveRecord::Migration
  def change
    create_table :statistic_by_volumes do |t|
      t.integer :count
      t.timestamps
    end
  end
end
