FactoryBot.define do
  factory :shopping_list do
    association :user
    sequence(:name) { |n| "Shopping List #{n}" }
    status { "active" }
  end
end
