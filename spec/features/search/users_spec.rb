require "rails_helper"

describe "searching for a user", type: :feature do
  it "allows searching for a user" do
    user = create(:user, first_name: "Josh", last_name: "Klina")
    user2 = create(:user, first_name: "Laura", last_name: "Klina")

    visit timeline_path(as: user2)
    fill_in("query", with: "Josh")
    click_button "Search"

    expect(page).to have_content("Josh Klina")
    expect(page).to_not have_content("Laura Klina")
  end
end
