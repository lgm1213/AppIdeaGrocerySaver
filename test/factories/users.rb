FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@test.com" }
    password { "password123456" }
    onboarding_complete { true }
    onboarding_step     { "complete" }
  end
end
