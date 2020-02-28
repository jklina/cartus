require 'rails_helper'

describe "displaying a user profile page", type: :feature do
  it "signs me in" do
    user = create(:user)
    visit user_path(user)
    expect(page).to have_content(user.email)
  end
end
