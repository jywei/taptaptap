namespace :stats do
  desc "data state"
  task :save_hourly_stats_to_db => :environment do
    StatisticLive.save_to_db
  end

  desc "delete old zipcode statistics redis keys"
  task :delete_old_zips_stat => :environment do
    ZipsTracker.delete_old_redis_keys
  end

  desc "delete old redis keys"
  task :delete_old_keys => :environment do
    RedisHelper.delete_old_keys
  end

  desc "collect latency"
  task :collect_latency => :environment do
    LatencyStatisticsRunner.perform
  end

  desc "hourly latency"
  task :save_hourly_latency => :environment do
    AverageLatencyRunner.save_hourly_latency
  end

  desc "save statistics on transfered data to db and delete redundant keys from redis"
  task :save_transfered_data_stats => :environment do
    StatisticByTransferedData.flush_to_db
  end

  desc "save heartbeats to db and delete redundant keys from redis"
  task :save_heartbeats_stat => :environment do
    StatisticByHeartbeat.flush_to_db
  end

  desc "save updates statistic to db and remove it from redis"
  task :save_updates_stat => :environment do
    StatisticByUpdates.flush_to_db
  end

  desc "collect annotations from volume"
  task :collect_annotations => :environment do
    AnnotationsLocation.fill
  end

  desc "remove old annotations stats"
  task :delete_old_annotations_stats => :environment do
    AnnotationsLocation.remove_old_data
  end

  desc "save statistics by empty images to db"
  task :save_empty_images => :environment do
    StatisticByEmptyImage.flush_to_db
  end
end
