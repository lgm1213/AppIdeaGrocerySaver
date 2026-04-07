FactoryBot.define do
  factory :meal_plan do
    association :user
    sequence(:name)   { |n| "Meal Plan #{n}" }
    week_start_date   { Date.current.beginning_of_week(:monday) }
    status            { "active" }

    trait :with_entries do
      after(:create) do |plan|
        recipe = create(:recipe, meal_type: "dinner")
        plan.meal_plan_entries.create!(
          day_of_week: 0,
          meal_slot:   "dinner",
          servings:    2,
          recipe:      recipe
        )
      end
    end

    trait :archived do
      status { "archived" }
    end
  end
end
