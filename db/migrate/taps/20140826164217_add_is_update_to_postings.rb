class AddIsUpdateToPostings < ActiveRecord::Migration
  def change
    start_vol = Posting2.current_volume == 0 ? 0 : Posting2.current_volume + 1

    (start_vol).upto(LastVolume.last_volume) do |volume|
      add_column "postings#{volume}", :is_update, :boolean, default: false
    end
  end
end
