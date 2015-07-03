class AddSourceToAverageQuality < ActiveRecord::Migration
  def change
    add_column :average_qualities, :source, 'char(5)'
  end
end
