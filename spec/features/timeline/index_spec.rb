require "rails_helper"

describe "a user's timeline", type: :feature do
  it "signs me in" do
    user1 = create(:user)
    user1_post = create(:post, user: user1, body: "user 1 post")
    user2 = create(:user)
    user2_post = create(:post, user: user2, body: "user 2 post")
    user3 = create(:user)
    user3_post = create(:post, user: user3, body: "user 3 post")
    user4 = create(:user)
    user4_post = create(:post, user: user4, body: "user 4 post")

    create(:relationship, relatee: user1, related: user2, accepted: true)
    create(:relationship, relatee: user1, related: user3, accepted: true)
    create(:relationship, relatee: user4, related: user1, accepted: true)

    visit timeline_path(as: user1)

    expect(page).to have_content("user 2 post")
    expect(page).to have_content("user 3 post")
    expect(page).to have_content("user 4 post")
  end
end
