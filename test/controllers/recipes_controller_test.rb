require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user       = create(:user)
    @ingredient = create(:ingredient, name: "Chicken")
    sign_in_as(@user)
  end

  # ── auth ───────────────────────────────────────────────────────────────────

  test "new redirects unauthenticated users" do
    sign_out
    get new_recipe_path
    assert_redirected_to new_session_path
  end

  test "create redirects unauthenticated users" do
    sign_out
    post recipes_path, params: { recipes_submission: { name: "X", meal_type: "dinner" } }
    assert_redirected_to new_session_path
  end

  # ── new ────────────────────────────────────────────────────────────────────

  test "new renders the recipe form" do
    get new_recipe_path
    assert_response :success
    assert_match "Add a Recipe", response.body
  end

  # ── create ─────────────────────────────────────────────────────────────────

  test "create with valid params creates a recipe and redirects to show" do
    assert_difference "Recipe.count", 1 do
      post recipes_path, params: {
        recipes_submission: {
          name:      "Grilled Chicken",
          meal_type: "dinner",
          servings:  "4",
          ingredient_rows: {
            "0" => { ingredient_id: @ingredient.id, quantity: "2", unit: "lb" }
          }
        }
      }
    end

    recipe = Recipe.last
    assert_equal "Grilled Chicken", recipe.name
    assert_equal "user_created",    recipe.source
    assert_redirected_to recipe_path(recipe)
    assert_match "successfully", flash[:notice]
  end

  test "create with invalid params re-renders new with errors" do
    assert_no_difference "Recipe.count" do
      post recipes_path, params: {
        recipes_submission: { name: "", meal_type: "dinner", ingredient_rows: {} }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with no ingredients re-renders new with errors" do
    assert_no_difference "Recipe.count" do
      post recipes_path, params: {
        recipes_submission: {
          name:            "Nameless",
          meal_type:       "lunch",
          ingredient_rows: {}
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
