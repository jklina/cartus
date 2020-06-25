require "rails_helper"

describe "editing a user", type: :feature do
  it "signs me in" do
    user = create(:user, first_name: "Joe", last_name: "Smith")

    visit edit_user_path(user, as: user)
    fill_in("First name", with: "Josh")
    fill_in("Last name", with: "Klina")
    select("male", from: "Gender")
    select("1982", from: "user_birthday_1i")
    select("November", from: "user_birthday_2i")
    select("19", from: "user_birthday_3i")
    click_button("Update Profile")

    expect(page).to have_content("Josh Klina")
    expect(page).to have_content("Male")
  end
end
