FactoryBot.define do
  factory :comment do
    body { "MyText" }
    user
    commentable { post }
  end
end
