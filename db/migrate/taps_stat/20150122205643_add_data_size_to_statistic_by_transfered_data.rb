class AddDataSizeToStatisticByTransferedData < ActiveRecord::Migration
  def change
    add_column :statistic_by_transfered_data, :data_size, :integer, default: 0
  end
end
