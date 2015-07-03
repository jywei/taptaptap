class AddIndexOnGeolocationStatusId < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      add_index "postings#{volume}", [:geolocation_status, :id], name: "index_postings#{volume}_on_geolocation_status_and_id" unless index_exists?("postings#{volume}", [:geolocation_status, :id])
    end
  end
end
