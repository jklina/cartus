
class RelationshipsController < ApplicationController
  def create
    @related = User.find(relationship_params.fetch(:related_id))
    @relationship = Relationship.new(relatee: current_user, related: @related, accepted: false)
    if @relationship.save
      flash.notice = "An invitation has been sent"
    else
      flash.alert = "There was a problem adding this relationship"
    end
      redirect_to @related
  end

  private

  def relationship_params
    params.require(:relationship).permit(:related_id)
  end
end
