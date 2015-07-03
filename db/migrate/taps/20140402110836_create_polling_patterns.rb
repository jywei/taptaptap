class CreatePollingPatterns < ActiveRecord::Migration
  def change
    create_table :polling_patterns do |t|
      t.string :pattern_keys
      t.string :request_params
    end
  end
end
