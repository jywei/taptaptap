class Notification::EmptyStatus < Notification
  def self.postings_count
    @postings_count ||= db.query("SELECT count(*) FROM postings#{volume} WHERE created_at > '#{Notification.interval.ago.to_s(:db)}' and status = ''")
    .first.first[1]
  end

  def self.notify
    postings_count != 0
  end

  def self.message
    ['Created postings with empty status', 'Created postings with empty status']
  end
end
