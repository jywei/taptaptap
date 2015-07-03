class AddSourceMetroIndexOnPostings < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |i|
      add_index "postings#{i}", ['source', 'metro']
    end
  end
end
