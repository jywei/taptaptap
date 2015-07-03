class AddIndexOnCategoryGroupMetroAndId < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      index_name = "index_postings#{volume}_on_category_group_metro_id"
      index_columns = [:category_group, :metro, :id]

      next if index_exists?("postings#{volume}", index_columns)

      add_index "postings#{volume}", index_columns, name: index_name
    end
  end
end
