FactoryBot.define do
  factory :store do
    chain { "publix" }
    sequence(:name) { |n| "Publix ##{n}" }
    city  { "Miami" }
    state { "FL" }
  end
end
