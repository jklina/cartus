require "rails_helper"

describe "displaying a user profile page", type: :feature do
  it "signs me in" do
    user = create(:user, first_name: "Joe", last_name: "Smith")

    visit user_path(user)

    expect(page).to have_content("Joe Smith")
  end
end
