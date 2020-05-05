require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe "DELETE #destroy" do
    it "destroys a given post" do
      user = create(:user)
      user_post = create(:post, user: user, body: "Post content")
      sign_in_as(user)

      delete :destroy, params: { id: user_post.id }

      expect(response).to redirect_to user_path(user)
      expect(Post.all.size).to be_zero
    end

    it "doesn't destroy another user's post" do
      user = create(:user)
      foreign_user = create(:user)
      user_post = create(:post, user: user, body: "Post content")
      sign_in_as(foreign_user)

      expect do
        delete :destroy, params: { id: user_post.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
