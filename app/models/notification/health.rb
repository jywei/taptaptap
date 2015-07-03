class Notification::Health < Notification
  def self.notify
    @errors = []

    volume = Posting2.current_volume
    Posting.table_name = "postings#{volume}"
    Posting.primary_key = 'id'

    posting = Posting.last

    @errors << "Last posting more than 30 minutes ago" if Time.now - posting.created_at > 30.minutes

    !@errors.empty?
  end

  def self.message
    [@errors.join('; '), 'health warning', ['marat@3taps.com', 'andrey@3taps.com']]
  end
end