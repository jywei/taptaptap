class CreateAustralianZipcodes < ActiveRecord::Migration
  def change
    create_table :australian_zipcodes do |t|
      t.string :zipcode, limit: 9
      t.string :suburb, limit: 50
      t.string :metro, limit: 7
      t.string :state, limit: 7
      t.string :country, limit: 3
      t.decimal :latitude, precision: 6, scale: 3
      t.decimal :longitude, precision: 6, scale: 3

    end
  end
end
