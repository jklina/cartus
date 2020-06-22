require "rails_helper"

describe "a user's list of invitations", type: :feature do
  it "lists the pending invitations" do
    user = create(:user)
    invitation_sender = create(:user, first_name: "Josh", last_name: "Klina")
    invitation_receiver = create(:user, first_name: "Laura", last_name: "Klina")

    create(:relationship, relatee: user, related: invitation_receiver, accepted: false)
    create(:relationship, relatee: invitation_sender, related: user, accepted: false)

    visit invites_path(as: user)

    expect(page).to have_content("Josh Klina")
    expect(page).to have_content("Laura Klina")
  end

  it "lists the pending invitations" do
    invitation_sender = create(:user, first_name: "Josh", last_name: "Klina")
    invitation_receiver = create(:user, first_name: "Laura", last_name: "Klina")

    create(:relationship, relatee: invitation_sender, related: invitation_receiver, accepted: false)

    visit invites_path(as: invitation_receiver)

    expect(page).to have_content("Josh Klina")
    expect(page).to_not have_content("Laura Klina")
  end

  it "allows an invitation to be canceled" do
    invitation_sender = create(:user)
    invitation_receiver = create(:user, first_name: "Laura", last_name: "Klina")

    create(:relationship, relatee: invitation_sender, related: invitation_receiver, accepted: false)

    visit invites_path(as: invitation_sender)
    click_on("Cancel")

    expect(page).to have_current_path(invites_path(as: invitation_sender))
    expect(page).to have_content("This invite has been revoked")
    expect(page).to_not have_content("Laura Klina")
  end

  it "allows an invitation to be declined" do
    invitation_receiver = create(:user)
    invitation_sender = create(:user, first_name: "Laura", last_name: "Klina")

    create(:relationship, relatee: invitation_sender, related: invitation_receiver, accepted: false)

    visit invites_path(as: invitation_receiver)
    click_on("Decline")

    expect(page).to have_current_path(invites_path(as: invitation_receiver))
    expect(page).to have_content("This invite has been declined")
    expect(page).to_not have_content("Laura Klina")
  end

  it "allows an invitation to be accepted" do
    invitation_receiver = create(:user)
    invitation_sender = create(:user, first_name: "Laura", last_name: "Klina")

    relationship = create(:relationship, relatee: invitation_sender, related: invitation_receiver, accepted: false)

    visit invites_path(as: invitation_receiver)
    click_on("Accept")
    relationship.reload

    expect(page).to have_current_path(invites_path(as: invitation_receiver))
    expect(page).to have_content("You accepted the invitation")
    expect(page).to_not have_content("Laura Klina")
    expect(relationship.accepted?).to be_truthy
  end
end
