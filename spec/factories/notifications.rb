FactoryBot.define do
  factory :notification do
    target { nil }
    read { false }
    user { nil }
  end
end
