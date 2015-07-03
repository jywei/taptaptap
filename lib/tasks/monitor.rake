namespace :monitor do
  desc "data state"
  task :data_state => :environment do
    Notification.send_notifications if Rails.env.production?
  end

  task :columns_overflow => :environment do
    Notification.send_notification(Notification::ColumnsOverflow) if Rails.env.production?
    Notification::ColumnsOverflow.clear_overflows
  end

  task :craig_geolocation => :environment do
    SystemMonitor.structure_of_craig_geolocations if Rails.env.production?
  end

  task :source_counts => :environment do
    SystemMonitor.counts_by_source if Rails.env.production?
  end

  task :rejected_count => :environment do
    SystemMonitor.rejected_count if Rails.env.production?
  end

  task :free_space => :environment do
    FreeSpace.record_amount if Rails.env.production?
  end

  task :redis_free_space => :environment do
    SystemMonitor.check_redis_free_mem # if Rails.env.production?
  end

  task :system_monitor => :environment do
    SystemMonitor.system_monitor if Rails.env.production?
  end

  task :deleted_counts => :environment do
    SystemMonitor.deleted_counts if Rails.env.production?
  end

  task :added_counts => :environment do
    SystemMonitor.added_counts if Rails.env.production?
  end

  task :new_annotations => :environment do
    SystemMonitor.new_annotations if Rails.env.production?
  end

  task :exceptions => :environment do
    return unless Rails.env.production?

    exc = TapsException.daily
    modules = exc.collect(&:module_name).compact.uniq

    modules.each do |m|
      SystemEvent.create event: "#{m} module: #{ exc.select { |e| e.module_name == m }.size } exceptions"
    end
  end

  task :cleanup_exceptions => :environment do
    TapsException.cleanup!
  end

  task :process_single_exceptions => :environment do
    url = case Rails.env
            when :production then 'posting3.3taps.com'
            when :staging then 'staging-posting.3taps.com'
            else 'localhost:3000'
          end

    TapsExceptionsRunner.resend_single_posting url
  end

  task :process_batch_exceptions => :environment do
    url = case Rails.env
            when :production then 'posting3.3taps.com'
            when :staging then 'staging-posting.3taps.com'
            else 'localhost:3000'
          end

    TapsExceptionsRunner.resend_all_postings url
  end

  task :shift_volume => :environment do
    return unless Rails.env.production?

    num = FreeSpace.amount
    volumes_difference = LastVolume.last_volume - Posting2.current_volume

    if num > 80 || volumes_difference <= 7
      FirstVolume.bump_1_table
    end
  end

  task :system_events_daily => :environment do
    events = SystemEvent.daily
    NotificationMailer.daily_events(events).deliver! if Rails.env.production?
  end

  task :polling_timeouts_daily => :environment do
    NotificationMailer.polling_timeouts.deliver! if Rails.env.production?
  end

  task :constant_updates => :environment do
    PostingConstants.check_updates_for :category_groups
    PostingConstants.check_updates_for :categories
  end

  task :average_quality => :environment do
    AverageQuality.flush_to_db(Date.today.prev_day)
  end

  task :clear_idle_sources => :environment do
    SystemMonitor.clear_idle_sources
  end

  task :metro_postings_stat => :environment do
    StatisticByMetro.flush_to_db
    NotificationMailer.postings_by_metro_and_category.deliver! if Rails.env.production?
  end

  task :clear_logs => :environment do
    masks = [
        File.join(Rails.root, %w(log custom requests create), '**/*'),
        File.join(Rails.root, %w(log custom requests poll), '**/*')
    ]

    masks.each do |mask|
      Dir.glob(mask).select do |filename|
        timestamp = filename.gsub /^(\d+)\.log$/, '\1'

        Time.parse(timestamp) < (Time.now - 1.week)
      end.each do |filename|
        `rm #{filename}`
      end
    end
  end
end
