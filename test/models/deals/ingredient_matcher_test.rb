require "test_helper"

class Deals::IngredientMatcherTest < ActiveSupport::TestCase
  setup do
    @matcher = Deals::IngredientMatcher.new
  end

  test "matches a deal whose name contains the ingredient name" do
    ingredient = create(:ingredient, name: "Chicken Breast")
    deal = create(:deal, name: "Boneless Chicken Breast Family Pack")

    matched = @matcher.match(Deal.where(id: deal.id))

    assert_equal 1, matched
    assert_equal ingredient, deal.reload.ingredient
  end

  test "does not match when no ingredient substring is found" do
    create(:ingredient, name: "Salmon Fillet")
    deal = create(:deal, name: "Organic Peanut Butter")

    matched = @matcher.match(Deal.where(id: deal.id))

    assert_equal 0, matched
    assert_nil deal.reload.ingredient
  end

  test "prefers the longest matching ingredient name" do
    create(:ingredient, name: "Beef")
    ground_beef = create(:ingredient, name: "Ground Beef")
    deal = create(:deal, name: "93% Lean Ground Beef 1 lb")

    @matcher.match(Deal.where(id: deal.id))

    assert_equal ground_beef, deal.reload.ingredient
  end

  test "matching is case-insensitive" do
    ingredient = create(:ingredient, name: "Shrimp")
    deal = create(:deal, name: "JUMBO SHRIMP 2 LB BAG")

    @matcher.match(Deal.where(id: deal.id))

    assert_equal ingredient, deal.reload.ingredient
  end

  test "returns total count of matched deals" do
    create(:ingredient, name: "Bacon")
    create(:ingredient, name: "Eggs")
    bacon_deal = create(:deal, name: "Thick Cut Bacon 16oz")
    eggs_deal  = create(:deal, name: "Large Eggs 12ct")
    create(:deal, name: "Paper Towels 6pk")

    matched = @matcher.match(Deal.all)

    assert_equal 2, matched
    assert_not_nil bacon_deal.reload.ingredient
    assert_not_nil eggs_deal.reload.ingredient
  end
end
