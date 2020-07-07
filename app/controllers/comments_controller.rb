class CommentsController < ApplicationController
  def create
    @user = current_user
    @comment = @user.comments.build(comment_params)
    if @comment.save
      Notification.create!(
        user: @comment.commentable.user,
        initiator: @user,
        target: @comment.commentable,
        message: "#{current_user.full_name} has commented on your #{@comment.commentable.class.name.titleize}."
      )
      flash.notice = "Your comment has been created."
      redirect_back(fallback_location: timeline_path)
    else
      flash.alert = "There was a problem saving your comment."
      redirect_back(fallback_location: timeline_path)
    end
  end

  def update
  end

  def destroy
    @user = current_user
    @comment = @user.comments.find(params[:id])
    if @comment.destroy
      flash.notice = "Your comment has been removed."
    else
      flash.alert = "Your comment has not been removed."
    end
    redirect_back(fallback_location: timeline_path)
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type)
  end
end
