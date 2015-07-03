class SetIdToUnsignedBigint < ActiveRecord::Migration
  def change
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
        execute "ALTER TABLE postings#{volume} MODIFY COLUMN `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    end
  end
end
