require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "redirects to the sign_in_path when not signed in" do
      get :index
      expect(response).to redirect_to sign_in_path
    end

    it "redirects to the user's path when signed in" do
      user = create(:user)
      sign_in_as(user)

      get :index

      expect(response).to redirect_to user_path(user)
    end
  end
end
