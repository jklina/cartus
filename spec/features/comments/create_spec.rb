require "rails_helper"

describe "creating a comment", type: :feature do
  it "creates a comment on a post for the signed in user" do
    user = create(:user)
    post = create(:post, user: user)

    visit post_path(post, as: user)

    fill_in("comment_body", with: "This is my comment.")
    click_button "Submit"

    expect(page).to have_current_path(post_path(post, as: user))
    expect(page).to have_content("Your comment has been created")
    expect(page).to have_content("This is my comment.")
  end
end
