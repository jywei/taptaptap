class AddIndexOnCategorySourceAndPostingState < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      add_index "postings#{volume}", [:category, :source, :posting_state], name: "index_postings#{volume}_on_category_and_source_and_posting_state"
    end
  end
end
