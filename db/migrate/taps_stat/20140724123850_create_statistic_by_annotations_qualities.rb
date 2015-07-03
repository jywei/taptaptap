class CreateStatisticByAnnotationsQualities < ActiveRecord::Migration
  def change
    create_table :statistic_by_annotations_qualities do |t|
    	t.column :source, 'char(5)'
      t.string :transit_ip_address
      t.date :for_date
      t.integer :quality, limit: 3
      t.integer :quantity, limit: 7
      t.timestamps
    end

    add_index :statistic_by_annotations_qualities, [:source, :for_date, :quality], unique: true, name: 'index_on_source_quality' 
  end
end
