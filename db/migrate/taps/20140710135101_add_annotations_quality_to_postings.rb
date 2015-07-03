class AddAnnotationsQualityToPostings < ActiveRecord::Migration
  def up
    start_volume = [0, Posting2.current_volume - 1].max

    start_volume.upto(LastVolume.last_volume) do |volume|
      add_column "postings#{ volume }", :annotations_quality, :integer, :default => nil
    end
  end
end
