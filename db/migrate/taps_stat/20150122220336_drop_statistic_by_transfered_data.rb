class DropStatisticByTransferedData < ActiveRecord::Migration
  def change
    drop_table :statistic_by_transfered_data
  end
end
