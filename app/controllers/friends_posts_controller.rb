class FriendsPostsController < ApplicationController
  def new
    @friend = current_user.friends.find(params[:user_id])
    @post = @friend.posts_from_friends.build
    @post.images.build
  end

  def create
    @friend = current_user.friends.find(params[:user_id])
    @post = @friend.posts_from_friends.build(post_params)
    @post.user = current_user
    unassigned_images = current_user.images.unassigned
    if @post.save && unassigned_images.update_all(imageable_id: @post.id, imageable_type: "Post")
      Notification.create!(
        user: @friend,
        initiator: current_user,
        target: @post,
        message: "#{current_user.full_name} has posted on your page."
      )
      flash.notice = "Your post has been created."
      redirect_to @friend
    else
      flash.alert = "There was a problem saving your post."
      render "new"
    end
  end

  private

  def post_params
    params.require(:post).permit(:body, images: [])
  end
end
