require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  permissions :update? do
    it "lets the owner update their profile" do
      user = build(:user)

      expect(UserPolicy).to permit(user, user)
    end

    it "doesn't let a non-owner update a user's profile" do
      user = build(:user)
      non_owner = build(:user)

      expect(UserPolicy).to_not permit(user, non_owner)
    end
  end

  permissions :destroy? do
    it "lets the owner update their profile" do
      user = build(:user)

      expect(UserPolicy).to permit(user, user)
    end

    it "doesn't let a non-owner update a user's profile" do
      user = build(:user)
      non_owner = build(:user)

      expect(UserPolicy).to_not permit(user, non_owner)
    end
  end
end
