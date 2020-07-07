class NotificationsController < ApplicationController
  after_action :mark_as_read!

  def index
    @user = current_user
    @notifications = @user.notifications.unread
  end

  private

  def mark_as_read!
    @notifications.update_all(read: true)
  end
end
