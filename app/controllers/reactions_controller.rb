class ReactionsController < ApplicationController
  def create
    @user = current_user
    @reaction = @user.reactions.build(reaction_params)
    @reaction.save!
    flash.notice = "Liked!"
    redirect_back(fallback_location: timeline_path)
  end

  def destroy
    @user = current_user
    @reaction = @user.reactions.find(params[:id])
    @reaction.destroy!
    flash.notice = "Like removed"
    redirect_back(fallback_location: timeline_path)
  end

  private

  def reaction_params
    params.require(:reaction).permit(:sentiment, :content_type, :content_id)
  end
end
