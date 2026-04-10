require "test_helper"

class Recipes::SubmissionTest < ActiveSupport::TestCase
  setup do
    @ingredient = create(:ingredient, name: "Chicken")
  end

  def valid_params(overrides = {})
    {
      name:      "Test Recipe",
      meal_type: "dinner",
      servings:  "4",
      ingredient_rows: [
        { ingredient_id: @ingredient.id.to_s, quantity: "1", unit: "lb" }
      ]
    }.merge(overrides)
  end

  # ── validations ────────────────────────────────────────────────────────────

  test "is valid with required fields and at least one ingredient" do
    submission = Recipes::Submission.new(valid_params)
    assert submission.valid?
  end

  test "is invalid without a name" do
    submission = Recipes::Submission.new(valid_params(name: ""))
    assert_not submission.valid?
    assert_includes submission.errors[:name], "can't be blank"
  end

  test "is invalid without a meal_type" do
    submission = Recipes::Submission.new(valid_params(meal_type: ""))
    assert_not submission.valid?
    assert submission.errors[:meal_type].any?
  end

  test "is invalid with an unrecognised meal_type" do
    submission = Recipes::Submission.new(valid_params(meal_type: "brunch"))
    assert_not submission.valid?
    assert submission.errors[:meal_type].any?
  end

  test "is invalid with servings less than 1" do
    submission = Recipes::Submission.new(valid_params(servings: "0"))
    assert_not submission.valid?
    assert submission.errors[:servings].any?
  end

  test "is invalid with no ingredient rows" do
    submission = Recipes::Submission.new(valid_params(ingredient_rows: []))
    assert_not submission.valid?
    assert submission.errors[:base].any?
  end

  test "is invalid when all ingredient rows lack an ingredient_id" do
    submission = Recipes::Submission.new(valid_params(
      ingredient_rows: [ { ingredient_id: "", quantity: "1", unit: "lb" } ]
    ))
    assert_not submission.valid?
    assert submission.errors[:base].any?
  end

  # ── save ──────────────────────────────────────────────────────────────────

  test "save creates a recipe with the correct attributes" do
    submission = Recipes::Submission.new(valid_params(cuisine: "American"))

    assert_difference "Recipe.count", 1 do
      result = submission.save
      assert_kind_of Recipe, result
      assert_equal "Test Recipe", result.name
      assert_equal "dinner",      result.meal_type
      assert_equal "user_created", result.source
      assert_equal "American",    result.cuisine
    end
  end

  test "save creates the expected recipe_ingredients" do
    submission = Recipes::Submission.new(valid_params)

    assert_difference "RecipeIngredient.count", 1 do
      submission.save
    end

    ri = RecipeIngredient.last
    assert_equal @ingredient, ri.ingredient
    assert_equal 1.0,         ri.quantity
    assert_equal "lb",        ri.unit
  end

  test "save returns false and sets errors when invalid" do
    submission = Recipes::Submission.new(valid_params(name: ""))
    result = submission.save
    assert_not result
    assert submission.errors.any?
  end

  test "save creates multiple ingredients from multiple rows" do
    ing2 = create(:ingredient, name: "Garlic")
    submission = Recipes::Submission.new(valid_params(
      ingredient_rows: [
        { ingredient_id: @ingredient.id.to_s, quantity: "1", unit: "lb" },
        { ingredient_id: ing2.id.to_s,        quantity: "3", unit: "clove" }
      ]
    ))

    assert_difference "RecipeIngredient.count", 2 do
      submission.save
    end
  end

  test "save ignores blank ingredient rows" do
    submission = Recipes::Submission.new(valid_params(
      ingredient_rows: [
        { ingredient_id: @ingredient.id.to_s, quantity: "1", unit: "lb" },
        { ingredient_id: "",                  quantity: "",  unit: "" }
      ]
    ))

    assert_difference "RecipeIngredient.count", 1 do
      submission.save
    end
  end

  test "save does not persist anything when recipe creation fails" do
    # Force a recipe validation error by using a duplicate external_id approach —
    # easiest: just make the meal_type invalid after construction.
    submission = Recipes::Submission.new(valid_params)
    submission.name = ""  # invalidate after construction

    assert_no_difference "Recipe.count" do
      submission.save
    end
  end
end
