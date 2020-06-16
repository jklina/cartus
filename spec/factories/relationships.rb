FactoryBot.define do
  factory :relationship do
    relatee { user }
    related { user }
  end
end
