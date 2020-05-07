require "rails_helper"

RSpec.describe ImagesController, type: :controller do
  describe "POST #create" do
    it "creates an image via xhr" do
      user = create(:user)
      sign_in_as(user)
      blob = ActiveStorage::Blob.create_after_upload!(
        io: File.open(Rails.root.join(file_fixture("kitten.jpg")), "rb"),
        filename: "kitten.jpg",
        content_type: "image/jpeg"
      )

      post :create, format: :json, params: {
        image: {
          description: "image 1",
          image: blob.signed_id
        }
      }

      expect(response.code).to eq("200")
      image_json = JSON.parse(response.body)
      expect(image_json.fetch("user_id")).to eq(user.id)
      expect(image_json.fetch("description")).to eq("image 1")
    end
  end
end
