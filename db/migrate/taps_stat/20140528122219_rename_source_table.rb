class RenameSourceTable < ActiveRecord::Migration
  def change
    rename_table :statistic_by_source, :statistic_by_sources
  end
end
