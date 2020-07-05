class NotificationsController < ApplicationController
  def index
    @user = current_user
    @notifications = @user.notifications.unread
  end
end
