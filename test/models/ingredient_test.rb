require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  # ── Validations ─────────────────────────────────────────────────────────────

  test "valid with required attributes" do
    ingredient = build(:ingredient)
    assert ingredient.valid?
  end

  test "invalid without a name" do
    ingredient = build(:ingredient, name: nil)
    assert ingredient.invalid?
    assert ingredient.errors[:name].any?
  end

  test "invalid with a duplicate name (case-insensitive)" do
    create(:ingredient, name: "Garlic")
    duplicate = build(:ingredient, name: "garlic")
    assert duplicate.invalid?
    assert duplicate.errors[:name].any?
  end

  test "invalid with an unrecognised category" do
    ingredient = build(:ingredient, category: "junk_food")
    assert ingredient.invalid?
    assert ingredient.errors[:category].any?
  end

  test "normalises name to titleize on save" do
    ingredient = create(:ingredient, name: "  whole wheat bread  ")
    assert_equal "Whole Wheat Bread", ingredient.name
  end

  # ── category_compatible? ────────────────────────────────────────────────────

  test "returns true when deal_category is nil" do
    ingredient = build(:ingredient, category: "meat")
    assert ingredient.category_compatible?(nil)
  end

  test "returns true when deal_category is blank string" do
    ingredient = build(:ingredient, category: "meat")
    assert ingredient.category_compatible?("")
  end

  test "returns true when deal_category contains a recognised hint" do
    ingredient = build(:ingredient, category: "meat")
    assert ingredient.category_compatible?("Meat & Poultry")
  end

  test "returns true for a dairy ingredient when deal_category is Dairy" do
    ingredient = build(:ingredient, category: "dairy")
    assert ingredient.category_compatible?("Dairy & Eggs")
  end

  test "returns false when deal_category has no overlap with the ingredient category" do
    # "Chicken" is meat — a broth deal should be rejected
    ingredient = build(:ingredient, category: "meat")
    refute ingredient.category_compatible?("Soup, Stocks & Broths")
  end

  test "returns false when deal_category is a completely unrelated category" do
    ingredient = build(:ingredient, category: "produce")
    refute ingredient.category_compatible?("Household & Cleaning")
  end

  test "category check is case-insensitive" do
    ingredient = build(:ingredient, category: "bakery")
    # hint is "bread" — deal category is uppercase
    assert ingredient.category_compatible?("BREAD & BAKERY")
  end

  test "returns true when ingredient category has no hints defined" do
    # If CATEGORY_DEAL_HINTS has no entry for this category, never block a match
    ingredient = build(:ingredient, category: "produce")
    # Stub an unknown category to verify the fallback
    allow_unknown = ingredient.dup
    allow_unknown.define_singleton_method(:category) { "unknown_future_category" }
    assert allow_unknown.category_compatible?("Some Retailer Category")
  end
end
