class CreateStatisticByEmptyImages < ActiveRecord::Migration
  def change
    create_table :statistic_by_empty_images do |t|
      t.string :source, limit: 5
      t.string :category, limit: 4
      t.date :for_date
      t.integer :amount

      t.timestamps
    end

    add_index :statistic_by_empty_images, [:source, :category, :for_date], unique: true, name: 'index_on_source_category_date'
  end
end
