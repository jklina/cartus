require "rails_helper"

describe "editing a user", type: :feature do
  it "signs me in" do
    user = create(:user, first_name: "Joe", last_name: "Smith")

    visit edit_user_path(user, as: user)
    fill_in("First name", with: "Josh")
    fill_in("Last name", with: "Klina")
    click_button("Update Profile")

    expect(page).to have_content("Josh Klina")
  end
end
