class AddKeyToAnnotationsLocations < ActiveRecord::Migration
  def change
    add_index :annotations_locations, [:source, :category, :annotation, :city, :country, :county, :locality, :metro, :region, :state, :zipcode], unique: true, name: "index_annotations_locations_unique_index"
  end
end
