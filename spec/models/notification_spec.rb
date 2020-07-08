require "rails_helper"

RSpec.describe Notification, type: :model do
  describe ".unread" do
    it "returns unread notifications" do
      read_notification = create(:notification, read: true)
      unread_notification = create(:notification, read: false)

      expect(Notification.unread).to eq([unread_notification])
    end
  end
end
