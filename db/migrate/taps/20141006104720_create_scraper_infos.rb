class CreateScraperInfos < ActiveRecord::Migration
  def change
    create_table :scraper_infos do |t|
      t.column :source, 'char(5)'
      t.integer :event_code
      t.string :message 
      t.timestamps
    end
  end
end
