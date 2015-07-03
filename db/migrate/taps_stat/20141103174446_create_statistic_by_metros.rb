class CreateStatisticByMetros < ActiveRecord::Migration
  def change
    create_table :statistic_by_metros do |t|
      t.date :for_date
      t.integer :count
      t.string :category
      t.string :metro
    end
  end
end
