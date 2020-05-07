FactoryBot.define do
  factory :image do
    title { "My image" }
    description { "My image" }
    user
    image do
      blob = ActiveStorage::Blob.create_after_upload!(
        io: File.open(Rails.root.join("spec/fixtures/files/kitten.jpg"), "rb"),
        filename: "kitten.jpg",
        content_type: "image/jpeg"
      )
      blob.signed_id
    end
  end
end
