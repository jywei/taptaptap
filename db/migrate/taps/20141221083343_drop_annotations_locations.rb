class DropAnnotationsLocations < ActiveRecord::Migration
  def up
    drop_table :annotations_locations
  end

  def down
    create_table :annotations_locations do |t|
      t.string :source, limit: 5
      t.string :category, limit: 4
      t.string :annotation, limit: 30
      t.string :country, limit: 10
      t.string :state, limit: 10
      t.string :metro, limit: 10
      t.string :region, limit: 11
      t.string :county, limit: 10
      t.string :city, limit: 12
      t.string :locality, limit: 12
      t.string :zipcode, limit: 9
      t.integer :count_occurrences, default: 0
      t.integer :total_count, default: 0
      t.integer :volume
      t.timestamps
    end

    add_index :annotations_locations, [:source, :category, :annotation, :city, :country, :county, :locality, :metro, :region, :state, :zipcode], unique: true, name: "index_annotations_locations_unique_index"
  end
end
