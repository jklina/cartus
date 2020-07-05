class InvitesController < ApplicationController
  def index
    @sent_invites = current_user.sent_invitations
    @received_invites = current_user.received_invitations
  end

  def create
    @related = User.find(relationship_params.fetch(:related_id))
    @relationship = Relationship.new(
      relatee: current_user,
      related: @related,
      accepted: false
    )
    if @relationship.save
      Notification.create!(
        user: @related,
        target: current_user,
        message: "You received a friend request from #{current_user.full_name}"
      )
      flash.notice = "An invitation has been sent"
    else
      flash.alert = "There was a problem sending this invite"
    end
    redirect_to @related
  end

  def update
    @relationship = Relationship.find(params[:id])
    @relationship.accepted = true
    if @relationship.save
      Notification.create!(
        user: @relationship.relatee,
        target: @relationship.related,
        message: "Your request has been accepted by #{@relationship.relatee.full_name}"
      )
      flash.notice = "You accepted the invitation!"
    else
      flash.alert = "There was a problem accepting the invitation"
    end
    redirect_back(fallback_location: timeline_path)
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    if @relationship.destroy
      flash.notice = if current_user == @relationship.relatee
        "This invite has been revoked"
      else
        "This invite has been declined"
      end
    else
      flash.alert = "There was a problem revoking this invite"
    end
    redirect_back(fallback_location: timeline_path)
  end

  private

  def relationship_params
    params.require(:relationship).permit(:related_id)
  end
end
