require 'action_mailer'

class NotificationMailer < ActionMailer::Base
  layout false
  helper NotificationHelper

  def notice(message, subject = "notice from 3taps", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'marat@3taps.com', 'andrey@3taps.com'])
    @message = message
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def notice_with_attachments(message, subject = "notice from 3taps", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'marat@3taps.com', 'andrey@3taps.com'], attachment_set = {})
    @message = message

    attachment_set.each do |k, v|
      attachments[k] = v
    end

    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def postings_by_metro_and_category(date = Date.yesterday, subject = "notice from 3taps (Antengo)", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'marat@3taps.com', 'mnakamura@3taps.com'])
    @categories = PostingConstants::MCR_CATEGORIES.sort
    @data = StatisticByMetro.get_data(date)
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def new_annotations_notice(annotations, subject = "New annotations", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'marat@3taps.com', 'andrey@3taps.com'])
    @annotations = annotations
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def geolocation_notice(geolocation_counts, time, subject = "notice from 3taps", addresses)
    @geolocation_counts = geolocation_counts
    @time = time
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def source_notice(counts, time, subject = "notice from 3taps", addresses)
    @counts = counts
    @time = time
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def deleted_notice(counts, total, t1, t2, subject = 'notice from 3taps', addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'marat@3taps.com', 'mnakamura@3taps.com', 'andrey@3taps.com', 'doug@livelovely.com', 'erik@livelovely.com'])
    @counts = counts
    @total = total
    @t1, @t2 = t1, t2
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def added_notice(added_counts, added_totals, updated_counts, by_source, date, subject = 'notice from 3taps (added postings)', addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'marat@3taps.com', 'mnakamura@3taps.com', 'psk379@gmail.com'])
    @added_counts = added_counts
    @added_totals = added_totals
    @updated_counts = updated_counts
    @by_source = by_source
    @date = date

    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def error_504(exception, params, subject = "504 error details", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'mnakamura@3taps.com', 'marat@3taps.com', 'andrey@3taps.com'])
    @e = exception
    @current_volume = "postings#{ Posting2.current_volume }"

    @index_columns = params.keys.map do |k|
      key = case k
              when 'anchor'
                'id'
              when 'state'
                'posting_state'
              when /^location\./
                k.gsub(/^location\./, '')
              else
                k
            end

      ActiveRecord::Base.connection.column_exists?(@current_volume, key) ? key : nil
    end.compact

    @index_columns = nil if ActiveRecord::Base.connection.index_exists?(@current_volume, @index_columns)

    @params = params
    processes = Posting2.connection.query("show full processlist;")
    @mysql_result = processes.to_a.select { |row| row['State'].present? and row['State'] != 'Waiting for table level lock' }

    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def error_504_with_mysql_stats(exception, params, mysql_processes = [], subject = "504 error details", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'mnakamura@3taps.com', 'marat@3taps.com', 'andrey@3taps.com'])
    @e = exception
    @current_volume = "postings#{ Posting2.current_volume }"

    mysql_processes.reject! { |p| p.blank? }

    @index_columns = params.keys.map do |k|
      key = case k
              when 'anchor'
                'id'
              when 'state'
                'posting_state'
              when /^location\./
                k.gsub(/^location\./, '')
              else
                k
            end

      ActiveRecord::Base.connection.column_exists?(@current_volume, key) ? key : nil
    end.compact

    @index_columns = nil if ActiveRecord::Base.connection.index_exists?(@current_volume, @index_columns)

    @params = params
    @mysql_processes = mysql_processes

    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def unknown_polling_pattern(pattern, subject = "Unknown polling pattern", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'mnakamura@3taps.com', 'marat@3taps.com', 'andrey@3taps.com'])
    @pattern = pattern

    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def daily_events(events, subject = "daily events", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'mnakamura@3taps.com', 'marat@3taps.com', 'andrey@3taps.com', 'psk379@gmail.com'])
    @events = events

    # make 'source counts' the first event in the email
    if events.present? and events.first.event != 'source counts'
      index = @events.index { |e| e.event == 'source counts' }
      @events[index], @events[0] = @events[0], @events[index] if index.present?
    end

    @time = Time.now
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end

  def polling_timeouts(subject = "polling timeout", addresses = ['b.savchuk@svitla.com', 'a.shoobovych@svitla.com', 'mnakamura@3taps.com', 'marat@3taps.com', 'andrey@3taps.com'])
    @timeouts = PollTimeout.daily.where("message LIKE '%lock%'")

    return if @timeouts.empty?

    @timeout = @timeouts.first
    @time = Time.now
    mail(to: addresses, subject: "#{Rails.env}: #{subject}", from: 'robot@3taps.com')
  end
end
