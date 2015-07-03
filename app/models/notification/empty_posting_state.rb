class Notification::EmptyPostingState < Notification
  def self.postings_count
    @postings_count ||= db.query("SELECT count(*) FROM postings#{volume} WHERE created_at > '#{Notification.interval.ago.to_s(:db)}' AND posting_state IS NULL")
    .first.first[1]
  end

  def self.notify
    postings_count != 0
  end

  def self.message
    ['Created postings with empty posting_state', 'Created postings with empty posting_state']
  end
end
