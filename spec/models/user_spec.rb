require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to have_many :posts }

  describe "#profile_image" do
    it "has one profile_image" do
      user = create(:user)
      image = create(:image, user: user, imageable: user)

      expect(user.profile_image).to eq(image)
    end
  end

  describe "#invited?" do
    it "returns true if there's an invitation by the current user" do
      user1 = create(:user)
      user2 = create(:user)
      relationship = create(:relationship, relatee: user1, related: user2, accepted: false)

      expect(user1.invited?(user2)).to be_truthy
    end

    it "returns false if there isn't an invitation by the current user" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)
      relationship = create(:relationship, relatee: user1, related: user2, accepted: false)

      expect(user1.invited?(user3)).to be_falsey
    end
  end
end
