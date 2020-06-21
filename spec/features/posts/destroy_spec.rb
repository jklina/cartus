require "rails_helper"

describe "destroying a post", type: :feature do
  it "destroying a post" do
    user = create(:user)
    user_post = create(:post, user: user, body: "Post content")
    visit user_path(user, as: user)

    expect(page).to have_content("Post content")

    click_link "delete-post"

    expect(page).to have_current_path(user_path(user))
    expect(page).to_not have_content("Post content")
  end
end
