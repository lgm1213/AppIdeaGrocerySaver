require "test_helper"

class Deals::IngredientMatcherTest < ActiveSupport::TestCase
  setup do
    @matcher = Deals::IngredientMatcher.new
  end

  # ── Basic name matching ─────────────────────────────────────────────────────

  test "matches a deal whose name contains the ingredient name" do
    ingredient = create(:ingredient, name: "Chicken Breast", category: "meat")
    deal = create(:deal, name: "Boneless Chicken Breast Family Pack", category: "Meat & Poultry")

    matched = @matcher.match(Deal.where(id: deal.id))

    assert_equal 1, matched
    assert_equal ingredient, deal.reload.ingredient
  end

  test "matching is case-insensitive" do
    ingredient = create(:ingredient, name: "Shrimp", category: "seafood")
    deal = create(:deal, name: "JUMBO SHRIMP 2 LB BAG", category: "Seafood")

    @matcher.match(Deal.where(id: deal.id))

    assert_equal ingredient, deal.reload.ingredient
  end

  test "returns 0 and leaves ingredient nil when no name or keyword matches" do
    create(:ingredient, name: "Salmon Fillet", category: "seafood")
    deal = create(:deal, name: "Paper Towels 6pk", category: "Household")

    matched = @matcher.match(Deal.where(id: deal.id))

    assert_equal 0, matched
    assert_nil deal.reload.ingredient
  end

  # ── Keyword expansion ───────────────────────────────────────────────────────

  test "matches via keyword when the deal name does not contain the ingredient name" do
    # "Whole Wheat Bread" is not a substring of "Dave's Killer Bread Organic"
    # but "bread" IS in the keywords array.
    ingredient = create(:ingredient, name: "Whole Wheat Bread", category: "bakery",
                                     keywords: [ "whole wheat bread", "bread", "loaf" ])
    deal = create(:deal, name: "Dave's Killer Bread Organic 27oz", category: "Bakery")

    matched = @matcher.match(Deal.where(id: deal.id))

    assert_equal 1, matched
    assert_equal ingredient, deal.reload.ingredient
  end

  test "matches via keyword when deal uses a plural form" do
    ingredient = create(:ingredient, name: "Blueberry", category: "produce",
                                     keywords: %w[blueberry blueberries])
    deal = create(:deal, name: "Fresh Blueberries 6oz Pack", category: "Produce")

    @matcher.match(Deal.where(id: deal.id))

    assert_equal ingredient, deal.reload.ingredient
  end

  # ── Longest-match ranking ───────────────────────────────────────────────────

  test "prefers the ingredient with the longest matching term over a shorter one" do
    # "Ground Beef" (12 chars) should beat "Beef" (4 chars) for this deal
    _beef       = create(:ingredient, name: "Beef",        category: "meat")
    ground_beef = create(:ingredient, name: "Ground Beef", category: "meat")
    deal = create(:deal, name: "93% Lean Ground Beef 1 lb", category: "Meat")

    @matcher.match(Deal.where(id: deal.id))

    assert_equal ground_beef, deal.reload.ingredient
  end

  test "keyword length counts toward ranking so a long keyword beats a short name" do
    # Ingredient A: name="Oats"      (4 chars), no keywords
    # Ingredient B: name="Something" (9 chars), keywords=["rolled oats"] (11 chars)
    # Deal contains "Rolled Oats" → keyword match length 11 > name match length 4
    _short = create(:ingredient, name: "Oats", category: "pantry")
    long   = create(:ingredient, name: "Something", category: "pantry",
                                  keywords: [ "rolled oats" ])
    deal   = create(:deal, name: "Quaker Rolled Oats 18oz", category: "Pantry")

    @matcher.match(Deal.where(id: deal.id))

    assert_equal long, deal.reload.ingredient
  end

  # ── Category guard ──────────────────────────────────────────────────────────

  test "does not match ingredient whose category is incompatible with the deal category" do
    # "Chicken" (meat) should NOT match a deal categorised as soup/broth
    create(:ingredient, name: "Chicken Breast", category: "meat")
    deal = create(:deal, name: "Swanson Chicken Broth 14oz", category: "Soup, Stocks & Broths")

    matched = @matcher.match(Deal.where(id: deal.id))

    assert_equal 0, matched
    assert_nil deal.reload.ingredient
  end

  test "matches when deal category contains a hint for the ingredient category" do
    ingredient = create(:ingredient, name: "Bacon", category: "meat")
    deal = create(:deal, name: "Oscar Mayer Thick Cut Bacon 16oz", category: "Meat & Poultry")

    @matcher.match(Deal.where(id: deal.id))

    assert_equal ingredient, deal.reload.ingredient
  end

  test "falls back to unfiltered candidates when all are filtered by category guard" do
    # If every candidate ingredient is filtered, we still return the best
    # candidate rather than nothing — avoids over-filtering on bad scraped categories.
    ingredient = create(:ingredient, name: "Eggs", category: "dairy")
    deal = create(:deal, name: "Large Eggs 18ct",
                  # "Breakfast" doesn't match any dairy hints, so the guard fires,
                  # but the fallback path should still match.
                  category: "Breakfast")

    matched = @matcher.match(Deal.where(id: deal.id))

    assert_equal 1, matched
    assert_equal ingredient, deal.reload.ingredient
  end

  test "always matches when the deal has no category" do
    ingredient = create(:ingredient, name: "Butter", category: "dairy")
    deal = create(:deal, name: "Land O Lakes Butter 1lb", category: nil)

    @matcher.match(Deal.where(id: deal.id))

    assert_equal ingredient, deal.reload.ingredient
  end

  # ── Scope and already-matched deals ─────────────────────────────────────────

  test "skips deals that are already matched via the default unmatched scope" do
    existing = create(:ingredient, name: "Olive Oil", category: "pantry")
    create(:ingredient, name: "Pasta", category: "pantry")
    # This deal already has an ingredient assigned — it must not be re-matched
    deal = create(:deal, :matched, name: "Barilla Pasta 16oz", ingredient: existing)

    # Use the default scope (Deal.unmatched.active); already-matched deals are excluded
    matched = @matcher.match

    assert_equal 0, matched
    assert_equal existing, deal.reload.ingredient
  end

  test "returns total count of newly matched deals" do
    create(:ingredient, name: "Bacon", category: "meat")
    create(:ingredient, name: "Eggs",  category: "dairy")
    bacon_deal = create(:deal, name: "Thick Cut Bacon 16oz",  category: "Meat")
    eggs_deal  = create(:deal, name: "Large Eggs 12ct",       category: "Dairy")
    create(:deal, name: "Paper Towels 6pk", category: "Household")

    matched = @matcher.match(Deal.all)

    assert_equal 2, matched
    assert_not_nil bacon_deal.reload.ingredient
    assert_not_nil eggs_deal.reload.ingredient
  end
end
