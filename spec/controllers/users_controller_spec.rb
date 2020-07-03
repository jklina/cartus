require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe UsersController do
    describe "#create" do
      context "with valid attributes" do
        it "creates user and sends confirmation email" do
          email = "user@example.com"

          expect {
            post :create, params: {
              user: {email: email, password: "password"}
            }
          }.to have_enqueued_mail(UserMailer, :registration_confirmation)
        end
      end
    end
  end
end
