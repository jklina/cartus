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

  describe "#friends_posts" do
    it "returns an ordered list of posts from all a user's relationships" do
      user1 = create(:user)
      user1_post = create(:post, user: user1)
      user2 = create(:user)
      user2_post = create(:post, user: user2)
      user3 = create(:user)
      user3_post = create(:post, user: user3)
      user4 = create(:user)
      user4_post = create(:post, user: user4)
      user5 = create(:user)
      user5_post = create(:post, user: user5)

      create(:relationship, relatee: user1, related: user2, accepted: true)
      create(:relationship, relatee: user1, related: user3, accepted: true)
      create(:relationship, relatee: user4, related: user1, accepted: true)

      expect(user1.friends_posts).to eq([user4_post, user3_post, user2_post, user1_post])
    end
  end
end
