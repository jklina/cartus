FactoryBot.define do
  factory :reaction do
    user
    content { post }
  end
end
