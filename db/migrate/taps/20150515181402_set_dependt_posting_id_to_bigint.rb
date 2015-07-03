class SetDependtPostingIdToBigint < ActiveRecord::Migration
  def change
    execute "ALTER TABLE backpage_source_postings MODIFY COLUMN `posting_id` BIGINT UNSIGNED DEFAULT NULL"
    execute "ALTER TABLE geo_batches MODIFY COLUMN `min_id` BIGINT UNSIGNED DEFAULT NULL"
    execute "ALTER TABLE geo_batches MODIFY COLUMN `max_id` BIGINT UNSIGNED DEFAULT NULL"
    execute "ALTER TABLE posting_stats MODIFY COLUMN `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    execute "ALTER TABLE posting_stats MODIFY COLUMN `posting_id` BIGINT UNSIGNED DEFAULT NULL"
    execute "ALTER TABLE posting_thresholds MODIFY COLUMN `posting_id` BIGINT UNSIGNED DEFAULT NULL"
    execute "ALTER TABLE posting_thresholds MODIFY COLUMN `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    execute "ALTER TABLE posting_validation_infos MODIFY COLUMN `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    execute "ALTER TABLE posting_validation_infos MODIFY COLUMN `posting_id` BIGINT UNSIGNED DEFAULT NULL"
    execute "ALTER TABLE raw_postings MODIFY COLUMN `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    execute "ALTER TABLE raw_postings MODIFY COLUMN `posting_id` BIGINT UNSIGNED DEFAULT NULL"
    execute "ALTER TABLE recent_anchors MODIFY COLUMN `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    execute "ALTER TABLE recent_anchors MODIFY COLUMN `anchor` BIGINT UNSIGNED DEFAULT NULL"
    # execute "ALTER TABLE statistic_by_latencies MODIFY COLUMN `posting_id` BIGINT UNSIGNED DEFAULT NULL"
  end
end
