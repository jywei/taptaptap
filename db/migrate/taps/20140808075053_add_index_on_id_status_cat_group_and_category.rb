class AddIndexOnIdStatusCatGroupAndCategory < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      add_index "postings#{volume}", [:id, :status, :category_group, :category], name: "index_postings#{volume}_on_id_status_category_group_category"
    end
  end
end
