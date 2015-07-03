class AddCategoryToStatisitcByTransferedData < ActiveRecord::Migration
  def change
    add_column :statistic_by_transfered_data, :category, :string, limit: 4, after: :category_group

    add_index :statistic_by_transfered_data, [:source, :category, :for_date], name: 'index_on_source_category'
  end
end
