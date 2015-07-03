class AddForDateToAverageQualities < ActiveRecord::Migration
  def change
    add_column :average_qualities, :for_date, :date
  end
end
