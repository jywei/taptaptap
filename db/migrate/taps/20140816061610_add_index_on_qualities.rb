class AddIndexOnQualities < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      add_index "postings#{volume}", [:fields_quality], name: "index_postings#{volume}_on_fields_quality"
      add_index "postings#{volume}", [:annotations_quality], name: "index_postings#{volume}_on_annotations_quality"
    end
  end
end
