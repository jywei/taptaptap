class Admin::NotificationsController < Admin::ApplicationController
  before_action :find_notification, only: :update

  def index
    @notifications = Notification.all
  end

  def update
    @notification.status = Notification::Statuses::NOT_SENT
    @notification.save
    redirect_to admin_notifications_path
  end

  private

  def find_notification
    @notification = Notification.find params[:id]
  end
end
