class AddWeightToCalculateAnnotations < ActiveRecord::Migration
  def change
    add_column :calculate_annotations, :weight, :integer, :default => 1
  end
end
