FactoryBot.define do
  factory :shopping_list_item do
    association :shopping_list
    sequence(:name) { |n| "Item #{n}" }
    category  { "produce" }
    position  { 0 }
    checked   { false }
  end
end
