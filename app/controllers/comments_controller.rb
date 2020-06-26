class CommentsController < ApplicationController
  def create
    @user = current_user
    @comment = @user.comments.build(comment_params)
    if @comment.save
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
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type)
  end
end
