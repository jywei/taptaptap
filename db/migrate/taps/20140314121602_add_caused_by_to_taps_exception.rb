class AddCausedByToTapsException < ActiveRecord::Migration
  def change
    add_column :taps_exceptions, :caused_by, :string
  end
end
