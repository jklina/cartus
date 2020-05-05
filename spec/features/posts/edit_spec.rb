require 'rails_helper'

describe "editing a post", type: :feature do
  it "edits a post" do
    user = create(:user)
    user_post = create(:post, user: user)
    visit edit_post_path(user_post, as: user)

    fill_in("post_body", with: "This is my updated text.")
    click_button "Update Post"

    expect(page).to have_current_path(user_path(user))
    expect(page).to have_content("This is my updated text.")
  end

  it "doesn't let a use edit another use's post" do
    user = create(:user)
    foreign_user = create(:user)
    user_post = create(:post, user: user)
    expect do
      visit edit_post_path(user_post, as: foreign_user)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
