class AddColumnsToSourceCategoryStatistics < ActiveRecord::Migration
  def change
      rename_column :source_category_statistics, :category, :category_group
      add_column :source_category_statistics, :auth_token, :string, limit:32, after: :category_group
      add_column :source_category_statistics, :ip, :string, limit:15, after: :auth_token

      add_index :source_category_statistics, [:source, :auth_token, :ip, :for_date], name: 'index_on_source_category_group'
  end
end
