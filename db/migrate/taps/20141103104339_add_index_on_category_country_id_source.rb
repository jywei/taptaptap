class AddIndexOnCategoryCountryIdSource < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      add_index "postings#{volume}", [:category, :country, :id, :source], name: "index_postings#{volume}_on_category_country_id_source"
    end
  end
end
