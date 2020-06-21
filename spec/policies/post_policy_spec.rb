require "rails_helper"

RSpec.describe PostPolicy, type: :policy do
  permissions :show? do
    it "lets the owner view the post" do
      user = build(:user)
      post = build(:post, user: user)

      expect(PostPolicy).to permit(user, post)
    end

    it "lets a friend of the owner view the post" do
      user = create(:user)
      friend = create(:user)
      relationship = create(:relationship, relatee: user, related: friend, accepted: true)
      post = create(:post, user: user)

      expect(PostPolicy).to permit(friend, post)
    end

    it "it doesn't allow a non friend to view the post" do
      user = create(:user)
      unaccepted_friend = create(:user)
      relationship = create(:relationship, relatee: user, related: unaccepted_friend, accepted: false)
      post = create(:post, user: user)

      expect(PostPolicy).not_to permit(unaccepted_friend, post)
    end
  end

  permissions :update? do
    it "lets the owner update the post" do
      user = build(:user)
      post = build(:post, user: user)

      expect(PostPolicy).to permit(user, post)
    end

    it "doesn't let a non-owner update the post" do
      user = build(:user)
      non_owner = build(:user)
      post = build(:post, user: user)

      expect(PostPolicy).to_not permit(non_owner, post)
    end
  end

  permissions :destroy? do
    it "lets the owner destroy the post" do
      user = build(:user)
      post = build(:post, user: user)

      expect(PostPolicy).to permit(user, post)
    end

    it "doesn't let a non-owner destroy the post" do
      user = build(:user)
      non_owner = build(:user)
      post = build(:post, user: user)

      expect(PostPolicy).to_not permit(non_owner, post)
    end
  end
end
