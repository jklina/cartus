FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@smartcare.io" }
    password { "password" }
  end
end
