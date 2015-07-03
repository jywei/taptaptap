class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.string  :name
      t.text    :categories
      t.text    :category_groups
      t.text    :sources
      t.string  :control_type, :default => 'text'
      t.text    :options
      t.boolean :override_all_sources_value, :default => nil
      t.boolean :override_all_categories_value, :default => nil
      t.boolean :override_all_category_groups_value, :default => nil
      t.boolean :public, :default => true
      t.text    :public_options

      t.timestamps
    end
  end
end
