class AddSourceCategoryGeoStatusCreatedAtIndexToPostings < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |i|
      add_index "postings#{i}", [:source, :geolocation_status, :category, :created_at], name: "index_postings_on_source_and_geo_and_category_and_created_at"
    end
  end
end
