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
end
