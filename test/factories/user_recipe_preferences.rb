FactoryBot.define do
  factory :user_recipe_preference do
    association :user
    association :recipe
    liked  { nil }
    rating { nil }
  end
end
