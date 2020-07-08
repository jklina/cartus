require "rails_helper"

describe "viewing notifications" do
  it "shows a list of the logged in user's unread notifications and marks as read" do
    user = create(:user)
    post = create(:post, recipient: user)
    notification = create(
      :notification,
      user: user,
      target: post,
      message: "A notification about a post",
      read: false
    )

    visit notifications_path(as: user)
    notification.reload

    expect(page).to have_content("A notification about a post")
    expect(notification.read?).to be_truthy
  end
end
