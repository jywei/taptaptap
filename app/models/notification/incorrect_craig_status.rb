class Notification::IncorrectCraigStatus < Notification
  def self.postings_count
    data = Notification.db.query("SELECT annotations, status FROM postings#{Notification.volume} WHERE created_at > '#{Notification.interval.ago.to_s(:db)}' AND source='CRAIG'").map{|value| [Oj.load(value['annotations'])['source_subcat'].to_s.split('|').last, value['status']] }
    count = 0
    data.each{ |item|
      status = Posting::CRAIG_STATUSES_BY_CAT[item.first]
      if status.present?
        count += 1 unless status == item.last
      else
        count += 1 unless item.last == 'for_sale'
      end
    }
    count
  end

  def self.notify
    postings_count != 0
  end

  def self.message
    ['Created CRAIG postings with incorrect status', 'Created CRAIG postings with incorrect status']
  end
end
