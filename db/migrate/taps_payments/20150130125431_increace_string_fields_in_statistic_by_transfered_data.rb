class IncreaceStringFieldsInStatisticByTransferedData < ActiveRecord::Migration
  def up
    change_column :statistic_by_transfered_data, :source, :string, limit: 255
    change_column :statistic_by_transfered_data, :category_group, :string, limit: 255
  end

  def down
    change_column :statistic_by_transfered_data, :source, :string, limit: 5
    change_column :statistic_by_transfered_data, :category_group, :string, limit: 4
  end
end
