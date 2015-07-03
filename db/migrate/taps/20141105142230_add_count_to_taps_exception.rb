class AddCountToTapsException < ActiveRecord::Migration
  def change
    add_column :taps_exceptions, :count, :integer, :default => 1
  end
end
