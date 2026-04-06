FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "Ingredient #{n}" }
    category { "produce" }
    default_unit { "each" }
    average_price { 1.99 }
  end
end
