namespace :db do
  desc "clear old information from insert_profilers, posting_stats, posting_thresholds"
  task :clear_old_information => :environment do
    tables = %w(insert_profilers posting_stats posting_thresholds)
    old_time = (Time.now().utc() - 30.days).to_s(:db)
    tables.each do |table|
      sql = "DELETE FROM #{table} where created_at < '#{old_time}';"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  desc "migrate statistics database"
  task :migrate_stat => :environment do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Base.establish_connection("taps_stat_#{ Rails.env }")
    ActiveRecord::Migrator.migrate("db/migrate_stat", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  desc "rollback statistics database"
  task :rollback_stat => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    ActiveRecord::Migration.verbose = true
    ActiveRecord::Base.establish_connection("taps_stat_#{ Rails.env }")
    ActiveRecord::Migrator.rollback("db/migrate_stat", step)
  end
end
