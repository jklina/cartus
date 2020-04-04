class PostsController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @post = @user.posts.build
    @post.images.build
  end

  def show
    @user = User.find(params[:user_id])
    @post = @user.posts.find(params[:id])
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

  def post_params
    params.require(:post).permit(:body, images: [])
  end
end
