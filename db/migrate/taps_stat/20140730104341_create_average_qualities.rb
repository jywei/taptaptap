class CreateAverageQualities < ActiveRecord::Migration
  def change
    create_table :average_qualities do |t|
      t.integer :postings
      t.float :fields_quality
      t.float :annotations_quality

      t.timestamps
    end
  end
end
