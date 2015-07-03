# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#

set :output, "log/cron.log"
set :environment, :production

every 1.minute do
  #rake "postings:monitor"
end

every 1.minute do
  #rake "postings:fetch_from_partner" - fetching from MLS fails, we need a new key but decided to go w/o them
  #rake "monitor:data_state"
  rake "monitor:system_monitor"
end

every 3.hours do
  command "cd /home/posting/posting/current && ./scripts/backpage.sh"
end

every 1.hour do
  #rake "postings:parse_bkpge"
  rake "monitor:shift_volume"
  rake "stats:save_heartbeats_stat"
  rake "stats:save_hourly_latency"
  rake "monitor:redis_free_space"
  # rake "stats:collect_annotations"
end

every '2 * * * *' do
  rake "stats:save_hourly_stats_to_db"
end

every 1.day, :at => '12:00 am' do
  rake "monitor:categories_update_notice"
  rake "monitor:source_counts"
  rake "monitor:rejected_count"
  rake "monitor:added_counts"
  rake "monitor:clear_idle_sources"
  # rake "monitor:metro_postings_stat"
end

every 1.day, at: '12:08 am' do
  rake "monitor:exceptions"
  rake "monitor:cleanup_exceptions"
  rake "monitor:average_quality"
end

every 1.day, at: '12:12 am' do
  rake "stats:save_transfered_data_stats"
  rake "stats:save_updates_stat"
  rake "stats:delete_old_zips_stat"
  rake "stats:delete_old_annotations_stats"
end

every 1.day, at: '12:16 am' do
  rake "monitor:system_events_daily"
  rake "monitor:polling_timeouts_daily"
  rake "monitor:free_space"
  rake "stats:delete_old_keys"
end

every 1.day, :at => '7:01 pm' do
  rake "monitor:deleted_counts"
end

every 1.day, :at => '6:55 pm' do
  rake "monitor:columns_overflow"
end

every 1.day, :at => '12:00 am' do
  rake "postings:truncate_validations"
end

every 1.day, :at => '12:00 am' do
  rake "monitor:craig_geolocation"
end

every 1.day, :at => '4:10 pm' do
  rake "stats:save_empty_images"
end

