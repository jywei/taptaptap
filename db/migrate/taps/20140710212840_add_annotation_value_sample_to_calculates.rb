class AddAnnotationValueSampleToCalculates < ActiveRecord::Migration
  def change
    add_column :calculate_annotations, :sample_value, :string
  end
end
