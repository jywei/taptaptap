class Notification < ActiveRecord::Base
  class Statuses
    NOT_SENT = 0
    SENT = 1
  end

  NOTIFICATIONS = [
      Notification::Health,
      Notification::PostingValidationInfo,
      Notification::PostingVolume,
      #Notification::Ebaym,
      #Notification::Craig,
      Notification::Health,
      #Notification::Hmngs,
      #Notification::Remls,
      Notification::EmptyPostingState,
      Notification::EmptyStatus,
      #Notification::IncorrectCraigStatus,
      Notification::AnchorIsSlow,
      #Notification::FreeSpace,
      Notification::SystemState
      #Notification::Carsd
  ]

  def self.send_notification(notification)
    if (sample = notification.first) && sample.ready? || sample.nil?
      if notification.notify
        sample.nil? ?
            sample = notification.create(status: Statuses::SENT) :
            sample.update_attributes(status: Statuses::SENT)

        NotificationMailer.notice(*sample.class.message).deliver!
      else
        sample.nil? ?
            notification.create :
            sample.update_column(:status, Statuses::NOT_SENT)
      end
    end
  end

  def self.send_notifications
    NOTIFICATIONS.each do |n|
      self.send_notification n
    end

    nil
  end

  def ready?
    (
      (Time.now - self.updated_at > Notification.interval) &&
      self.status == Statuses::NOT_SENT
    ) || (
      [Notification::AnchorIsSlow,Notification::FreeSpace,Notification::PostingVolume,Notification::Craig,Notification::SystemState].include?(self.class) &&
      (Time.now - self.updated_at > Notification.long_interval) # to send notifications which are set to SENT but time has passed (not to miss a new event)
    )
  end

  protected

  def self.db
    @db = Posting2.connection
  end

  def self.interval
    1.minute
  end

  def self.long_interval
    1.hour
  end

  def self.volume
    @volume ||= db.query("SELECT volume from current_volume;").try(:first).try(:[], 'volume').try(:to_i)
  end
end
