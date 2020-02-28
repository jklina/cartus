require 'rails_helper'

describe "creating a post", type: :feature do
  it "signs me in" do
    user = create(:user)
    visit new_user_post_path(user)

    fill_in("Body", with: "This is my post.")
    click_button "Create Post"

    expect(page).to have_current_path(user_path(user))
    expect(page).to have_content("This is my post.")
  end
end
