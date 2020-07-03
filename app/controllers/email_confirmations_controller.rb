class EmailConfirmationsController < ApplicationController
  def update
    user = User.find_by!(email_confirmation_token: params[:token])
    user.confirm_email!
    sign_in user
    redirect_to timeline_path, notice: "Your email has been confirmed!"
  end
end
