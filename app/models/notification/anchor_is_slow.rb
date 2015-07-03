class Notification::AnchorIsSlow < Notification
  ALLOWED_GAP = 40_000

  def self.notify
    if (gap = last_posting_id - RecentAnchor.anchor) > ALLOWED_GAP

      #fixing logic
      volume = Posting2.current_volume
      Posting.table_name = "postings#{volume}"
      id = last_posting_id + ALLOWED_GAP

      return true

      last_posting = Posting.where(geolocation_status: Posting::GeoStatus::LOCATED).last

      condition = "geolocation_status = #{Posting::GeoStatus::LOCATING} and id >= #{current_anchor} and id <= #{id}"
      count = Posting.where(condition).count
      count2 = 0
      while count != count2

      end


      Posting.update_all({geolocation_status: Posting::GeoStatus::TO_LOCATE}, condition)
      NotificationMailer.notice("#{count} statuses updated", "#{count} statuses updated", ["marat@3taps.com", "andrey@3taps.com"]).deliver!
      return false
 

      posting_on_select_to_locate = nil
      return true
      while posting_on_select_to_locate.nil?
        posting_on_select_to_locate = Posting.where(geolocation_status: Posting::GeoStatus::ON_SELECT_TO_LOCATE).reorder('id asc').limit(1).to_a.first
      end

      if posting_on_select_to_locate
        current_anchor = Posting2.default_anchor
     else
        true
      end
    else
      p "Gap between anchor and last inserted posting is #{gap}"
      false
    end
  end

  def self.message
    ['Anchor is slow', 'Anchor is slow']
  end

  private

  def self.last_posting_id
    db.query("SELECT MAX(id) as last_id FROM postings#{volume};").try(:first).try(:[], 'last_id').try(:to_i)
  end
end
