class CreateAnnotationsLocationsProd < ActiveRecord::Migration
  def change
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
      t.integer :count_occurrences
      t.integer :total_count
      t.integer :volume
      t.timestamps
    end
  end
end
