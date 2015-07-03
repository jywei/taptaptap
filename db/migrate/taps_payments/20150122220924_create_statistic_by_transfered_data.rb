class CreateStatisticByTransferedData < ActiveRecord::Migration
  create_table :statistic_by_transfered_data do |t|
      t.string :source, limit: 5
      t.string :category_group, limit: 4
      t.string :auth_token, limit: 32
      t.string :ip, limit:15
      t.date :for_date
      t.integer :amount
      t.integer :data_size
      t.string :direction
      t.timestamps
  end

  add_index :statistic_by_transfered_data, [:source, :for_date], name: 'index_on_source_category_group'
end
