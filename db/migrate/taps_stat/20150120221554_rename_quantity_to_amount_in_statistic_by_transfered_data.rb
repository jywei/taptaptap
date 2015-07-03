class RenameQuantityToAmountInStatisticByTransferedData < ActiveRecord::Migration
  def change
    rename_column :statistic_by_transfered_data, :quantity, :amount
  end
end
