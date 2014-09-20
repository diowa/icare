class NotificationsController < ApplicationController

  after_filter :consume_notifications, only: :index

  def index
    @notifications = current_user.notifications.desc(:created_at)
  end

  protected
  def consume_notifications
    current_user.notifications.unread.update(unread: false)
  end
end
