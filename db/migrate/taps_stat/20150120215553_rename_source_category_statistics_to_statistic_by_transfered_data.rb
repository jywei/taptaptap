class RenameSourceCategoryStatisticsToStatisticByTransferedData < ActiveRecord::Migration
  def change
    rename_table :source_category_statistics, :statistic_by_transfered_data
  end
end
