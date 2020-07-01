require "rails_helper"

describe "creating a post", type: :feature do
  it "creates a post on the current user's page" do
    user = create(:user)
    friend = create(:user, first_name: "Kvothe")
    create(:relationship, relatee: user, related: friend, accepted: true)

    visit user_path(friend, as: user)
    click_link "Post on Kvothe's Page"

    fill_in("post_body", with: "This is my post.")
    click_button "Create Post"

    expect(page).to have_current_path(user_path(friend))
    expect(page).to have_content("This is my post.")
  end
end
