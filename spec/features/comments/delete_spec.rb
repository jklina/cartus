require "rails_helper"

describe "deleting a comment", type: :feature do
  it "creates a comment on a post for the signed in user" do
    user = create(:user)
    commenter = create(:user)
    create(:relationship, relatee: user, related: commenter, accepted: true)
    post = create(:post, user: user)
    comment = create(:comment, commentable: post, user: commenter, body: "My comment")

    visit post_path(post, as: commenter)
    click_link "remove-comment"

    expect(page).to have_current_path(post_path(post, as: commenter))
    expect(page).to have_content("Your comment has been removed")
    expect(Comment.all.size).to eq(0)
  end
end
