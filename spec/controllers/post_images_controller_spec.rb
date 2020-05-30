require "rails_helper"

RSpec.describe PostImagesController, type: :controller do
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

    it "doesn't create an invalid image via xhr" do
      user = create(:user)
      sign_in_as(user)

      post :create, format: :json, params: {
        image: {
          description: "image 1"
        }
      }

      expect(response.code).to eq("422")
      errors = JSON.parse(response.body)
      expect(errors.fetch("image").first).to eq("can't be blank")
    end
  end

  describe "DELETE #destroy" do
    it "destroys an image via xhr" do
      user = create(:user)
      sign_in_as(user)
      blob = ActiveStorage::Blob.create_after_upload!(
        io: File.open(Rails.root.join(file_fixture("kitten.jpg")), "rb"),
        filename: "kitten.jpg",
        content_type: "image/jpeg"
      )
      image = user.images.create!(image: blob.signed_id)

      delete :destroy, format: :json, params: {
        id: image.id
      }

      expect(response.code).to eq("204")
      expect(Image.all.size).to be_zero
    end
  end
end
