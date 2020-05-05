class ImagesController < ApplicationController
  def create
    @user = User.find(params[:user_id])
    @post = @user.posts.build(post_params)
    if @post.save
      flash.notice = "Your post has been created."
      redirect_to @user
    else
      flash.alert = "There was a problem saving your post."
      render "new"
    end
  end
end
