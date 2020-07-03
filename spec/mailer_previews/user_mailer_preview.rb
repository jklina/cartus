class UserMailerPreview < ActionMailer::Preview
  def registration_confirmation
    user = FactoryBot.build(:user, first_name: "Kvothe", email_confirmation_token: "123456")
    UserMailer.with(user).registration_confirmation
  end
end
