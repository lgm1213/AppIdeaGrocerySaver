FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe #{n}" }
    meal_type  { "dinner" }
    difficulty { "easy" }
    servings   { 4 }
    source     { "seed" }

    trait :breakfast do
      meal_type { "breakfast" }
    end

    trait :lunch do
      meal_type { "lunch" }
    end

    trait :dinner do
      meal_type { "dinner" }
    end
  end
end
