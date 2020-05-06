require "rails_helper"

RSpec.describe ImagesController, type: :controller do
  describe "POST #create" do
    it "creates multiple images via xhr" do
      user = create(:user)
      sign_in_as(user)
      blob = ActiveStorage::Blob.create_after_upload!(
        io: File.open(Rails.root.join(file_fixture("kitten.jpg")), "rb"),
        filename: "kitten.jpg",
        content_type: "image/jpeg"
      )

      post :create, format: :json, params: {
        images: [
          {
            description: "image 1",
            image: blob.signed_id
          },
          {
            description: "image 2",
            image: blob.signed_id
          }
        ]
      }

      expect(response).to be_ok
      images_json = JSON.parse(response.body)
      expect(images_json.map { |i| i.fetch("imageable_type") }).to all(eq "User")
      expect(images_json.map { |i| i.fetch("imageable_id") }).to all(eq user.id)
      expect(images_json.map { |i| i.fetch("description") })
        .to match_array(["image 1", "image 2"])
    end
  end
end
