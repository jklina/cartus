class PostsController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @post = @user.posts.build
  end

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

  def edit
    @user = User.find(params[:user_id])
    @post = @user.posts.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @post = @user.posts.find(params[:id])
    if @post.update(post_params)
      flash.notice = "Your post has been updated."
      redirect_to @user
    else
      flash.alert = "There was a problem saving your post."
      render "edit"
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @post = @user.posts.find(params[:id])
    if @post.destroy
      flash.notice = "Your post has been deleted."
      redirect_to @user
    else
      flash.alert = "Your post has not been deleted."
      redirect_to @user
    end
  end

  private
  # Using a private method to encapsulate the permissible parameters
  # is just a good pattern since you'll be able to reuse the same
  # permit list between create and update. Also, you can specialize
  # this method with per-user checking of permissible attributes.
  def post_params
    params.require(:post).permit(:body)
  end
end
