require "rails_helper"

describe "creating a post", type: :feature do
  it "creates a post for the signed in user" do
    user = create(:user)
    visit new_post_path(as: user)

    fill_in("post_body", with: "This is my post.")
    click_button "Create Post"

    expect(page).to have_current_path(user_path(user))
    expect(page).to have_content("This is my post.")
  end
end
