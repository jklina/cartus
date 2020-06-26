FactoryBot.define do
  factory :comment do
    body { "MyText" }
    user
    association :commentable, factory: :post
  end
end
