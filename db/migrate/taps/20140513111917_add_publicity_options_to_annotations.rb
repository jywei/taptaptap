class AddPublicityOptionsToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :sent_as_annotation, :boolean, :default => false
    add_column :annotations, :override_all_categories_in_group_value, :boolean, :default => nil
    rename_column :annotations, :public, :is_public
  end
end
