class AddSourceCategoryGroupIdIndexToPostings < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |i|
      add_index "postings#{i}", [:source, :category_group, :id], name: "index_postings_on_source_and_category_group_and_id"
    end
  end
end
