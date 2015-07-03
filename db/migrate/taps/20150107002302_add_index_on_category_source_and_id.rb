class AddIndexOnCategorySourceAndId < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      add_index "postings#{volume}", [:category, :source, :id], name: "index_postings#{volume}_on_category_source_id"
    end
  end
end
