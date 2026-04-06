FactoryBot.define do
  factory :deal do
    association :store
    sequence(:name) { |n| "Deal Item #{n}" }
    deal_type   { "sale" }
    sale_price  { 3.99 }
    savings_amount { 1.50 }
    valid_until { 30.days.from_now.to_date }
    category    { "Produce" }

    trait :bogo do
      deal_type      { "bogo" }
      sale_price     { nil }
      savings_amount { nil }
      badge_text     { "Buy 1 Get 1 Free" }
    end

    trait :multi do
      deal_type      { "multi" }
      multi_quantity { 2 }
      sale_price     { 5.00 }
      savings_amount { 2.00 }
    end

    trait :expired do
      valid_until { 7.days.ago.to_date }
    end

    trait :no_expiry do
      valid_until { nil }
    end

    trait :matched do
      association :ingredient
    end
  end
end
