FactoryBot.define do
  factory :notification do
    association :target, factory: :post
    read { false }
    user
    message { "You received a notification!" }
  end
end
