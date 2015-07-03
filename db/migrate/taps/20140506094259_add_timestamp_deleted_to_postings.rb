class AddTimestampDeletedToPostings < ActiveRecord::Migration
  def change
    Posting2.current_volume.upto(LastVolume.last_volume) do |i|
      add_column "postings#{i}", :timestamp_deleted, :integer
    end
  end
end
