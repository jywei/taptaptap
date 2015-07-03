class AddIndexOnSourceIdAndCategoryGroup < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      add_index "postings#{volume}", [ :source, :id, :category_group ], name: "index_postings#{volume}_on_source_id_category_group"
    end
  end
end
