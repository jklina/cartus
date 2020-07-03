require "rails_helper"

feature "User authentication", type: :feature do
  scenario "Visitor signs up, tries to sign in, confirms email and signs out" do
    visit root_path

    click_link "Sign up"

    fill_in "user_email", with: "clarence@example.com"
    fill_in "user_password", with: "password"
    click_button "Sign up"

    click_link "Sign in"

    fill_in "session_email", with: "clarence@example.com"
    fill_in "session_password", with: "password"
    click_button "Sign in"

    expect(page).to have_content("Please confirm your email address")

    user = User.last
    token = user.email_confirmation_token

    visit confirm_email_path(token: token)

    expect(page).to have_content "Your email has been confirmed"
    expect(current_path).to eq(timeline_path)
  end
end
