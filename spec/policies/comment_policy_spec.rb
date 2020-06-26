require "rails_helper"

RSpec.describe CommentPolicy, type: :policy do
  permissions :update? do
    it "lets the owner update the comment" do
      user = build(:user)
      comment = build(:comment, user: user)

      expect(CommentPolicy).to permit(user, comment)
    end

    it "doesn't let a non-owner update the comment" do
      user = build(:user)
      non_owner = build(:user)
      comment = build(:comment, user: user)

      expect(CommentPolicy).to_not permit(non_owner, comment)
    end
  end

  permissions :destroy? do
    it "lets the owner destroy the comment" do
      user = build(:user)
      comment = build(:comment, user: user)

      expect(CommentPolicy).to permit(user, comment)
    end

    it "doesn't let a non-owner destroy the comment" do
      user = build(:user)
      non_owner = build(:user)
      comment = build(:comment, user: user)

      expect(CommentPolicy).to_not permit(non_owner, comment)
    end
  end
end
