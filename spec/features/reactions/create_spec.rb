require "rails_helper"

describe "managing reactions" do
  describe "creating a reaction", type: :feature do
    it "creates a reaction" do
      user = create(:user)
      visitor = create(:user)
      post = create(:post, user: user)

      visit user_path(user, as: visitor)

      click_link "like"

      expect(page).to have_content("Liked!")
      reaction = Reaction.last
      expect(reaction.user).to eq(visitor)
      expect(reaction.content).to eq(post)
    end
  end

  describe "deleting a reaction", type: :feature do
    it "deletes an existing reaction" do
      user = create(:user)
      visitor = create(:user)
      post = create(:post, user: user)
      reaction = create(:reaction, user: visitor, content: post)

      visit user_path(user, as: visitor)

      click_link "remove-like"

      expect(page).to have_content("Like removed")
      expect(Reaction.all.size).to be_zero
    end
  end
end
