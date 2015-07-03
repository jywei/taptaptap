class AddCategoryGroupToCategoryStats < ActiveRecord::Migration
  def change
    add_column :statistic_by_categories, :category_group, :string, limit: 4
  end
end
