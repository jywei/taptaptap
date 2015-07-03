class RemovePublicOptionsFromAnnotations < ActiveRecord::Migration
  def change
    remove_column :annotations, :public_options
  end
end
