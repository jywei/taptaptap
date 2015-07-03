class AddDirectionToSourceCategoryStatistics < ActiveRecord::Migration
  def change
    add_column :source_category_statistics, :direction, :string
  end
end
