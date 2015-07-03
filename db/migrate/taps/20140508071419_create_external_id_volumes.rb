class CreateExternalIdVolumes < ActiveRecord::Migration
  def change
    create_table :external_id_volumes do |t|
      t.string     :external_id, limit: 20
      t.column     :source     , "char(5)"
      t.boolean    :deleted
      t.integer    :volume
      t.timestamps
    end

    add_index :external_id_volumes, [:external_id, :source]
  end
end
