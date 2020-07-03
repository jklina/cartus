class UserMailer < ApplicationMailer
  def registration_confirmation
    @user = params
    @confirmation_url = confirm_email_url(token: @user.email_confirmation_token)
    mail(to: @user.email, subject: "💌 Confirm Your Email Address")
  end
end
