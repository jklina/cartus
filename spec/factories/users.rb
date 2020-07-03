FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@smartcare.io" }
    password { "password" }
    email_confirmed_at { Date.today }
  end
end
