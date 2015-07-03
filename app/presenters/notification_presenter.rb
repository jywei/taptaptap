class NotificationPresenter < BasePresenter
  object :notification

  def type
    I18n.t("notification_types.#{notification.class.name.demodulize.underscore}")
  end

  def sent?
    notification.status == Notification::Statuses::SENT
  end

  def status
    sent? ? 'Sent' : 'Not Sent'
  end
end
