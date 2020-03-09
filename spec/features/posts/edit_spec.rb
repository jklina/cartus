require 'rails_helper'

describe "editing a post", type: :feature do
  it "edits a post" do
    user = create(:user)
    user_post = create(:post, user: user)
    visit edit_user_post_path(user, user_post)

    fill_in("post_body", with: "This is my updated text.")
    click_button "Update Post"

    expect(page).to have_current_path(user_path(user))
    expect(page).to have_content("This is my updated text.")
  end
end
