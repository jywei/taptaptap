class CreateStatisticBySource < ActiveRecord::Migration
  def change
    create_table :statistic_by_source do |t|
      t.column  :source, 'char(5)'
      t.integer :utc_hour
      t.integer :count
      t.date    :for_date
      t.boolean :deleted, default: false
      t.timestamps
    end
  end
end
