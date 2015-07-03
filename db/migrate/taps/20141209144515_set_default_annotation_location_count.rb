class SetDefaultAnnotationLocationCount < ActiveRecord::Migration
  def up
    change_column :annotations_locations, :count_occurrences, :integer, default: 0
    change_column :annotations_locations, :total_count, :integer, default: 0
  end

  def down
    change_column :annotations_locations, :count_occurrences, :integer
    change_column :annotations_locations, :total_count, :integer
  end
end
