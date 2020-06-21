class TimelineController < ApplicationController
  def index
    @user = current_user
    @posts = @user.friends_posts
  end
end
