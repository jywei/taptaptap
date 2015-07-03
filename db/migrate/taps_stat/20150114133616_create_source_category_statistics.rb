class CreateSourceCategoryStatistics < ActiveRecord::Migration
  def change
    create_table :source_category_statistics do |t|
      t.string :source, limit: 5
      t.string :category, limit: 4
      t.date :for_date
      t.integer :quantity
      t.timestamps
    end
  end
end
