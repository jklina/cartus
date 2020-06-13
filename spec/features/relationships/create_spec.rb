
require "rails_helper"

describe "creating a relationship", type: :feature do
  it "creates a relationship" do
    user = create(:user)
    related = create(:user)
    visit user_path(related, as: user)

    click_button "Send Friend Request"
    related.reload

    expect(page).to have_current_path(user_path(related))
    expect(page).to have_content("An invitation has been sent")
  end

  it "doesn't let a use edit another use's post" do
    user = create(:user)
    foreign_user = create(:user)
    user_post = create(:post, user: user)
    expect {
      visit edit_post_path(user_post, as: foreign_user)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
