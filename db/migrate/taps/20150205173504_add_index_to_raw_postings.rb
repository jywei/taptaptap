class AddIndexToRawPostings < ActiveRecord::Migration
  def change
    add_index :raw_postings, [ :validation_module, :created_at ]
  end
end
