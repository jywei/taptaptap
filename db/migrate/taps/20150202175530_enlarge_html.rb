class EnlargeHtml < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      change_column "postings#{volume}", :html, 'mediumtext'
    end
  end
end
