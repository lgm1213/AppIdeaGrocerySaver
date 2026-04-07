require "test_helper"

class MealPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
    @plan = create(:meal_plan, user: @user)
  end

  # ── index ──────────────────────────────────────────────────────────────────

  test "index renders successfully" do
    get meal_plans_path
    assert_response :success
  end

  test "index redirects unauthenticated users" do
    sign_out
    get meal_plans_path
    assert_redirected_to new_session_path
  end

  # ── new / create ───────────────────────────────────────────────────────────

  test "new renders form" do
    get new_meal_plan_path
    assert_response :success
  end

  test "create with valid params redirects to calendar" do
    next_week = Date.current.beginning_of_week(:monday) + 1.week
    post meal_plans_path, params: {
      meal_plan: { name: "Next Week", week_start_date: next_week }
    }
    plan = @user.meal_plans.find_by!(name: "Next Week")
    assert_redirected_to calendar_meal_plan_path(plan)
  end

  test "create with invalid params re-renders new" do
    post meal_plans_path, params: { meal_plan: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "create does not allow creating duplicate plan for same week" do
    post meal_plans_path, params: {
      meal_plan: { name: "Dup", week_start_date: @plan.week_start_date }
    }
    assert_response :unprocessable_entity
  end

  # ── edit / update ──────────────────────────────────────────────────────────

  test "edit renders form" do
    get edit_meal_plan_path(@plan)
    assert_response :success
  end

  test "update with valid params redirects to calendar" do
    patch meal_plan_path(@plan), params: { meal_plan: { name: "Renamed Plan" } }
    assert_redirected_to calendar_meal_plan_path(@plan)
    assert_equal "Renamed Plan", @plan.reload.name
  end

  test "update with invalid params re-renders edit" do
    patch meal_plan_path(@plan), params: { meal_plan: { name: "" } }
    assert_response :unprocessable_entity
  end

  # ── destroy ────────────────────────────────────────────────────────────────

  test "destroy deletes the plan and redirects" do
    assert_difference("MealPlan.count", -1) do
      delete meal_plan_path(@plan)
    end
    assert_redirected_to meal_plans_path
  end

  test "destroy cannot delete another user's plan" do
    other_plan = create(:meal_plan)
    delete meal_plan_path(other_plan)
    assert_response :not_found
  end

  # ── calendar ──────────────────────────────────────────────────────────────

  test "calendar renders the grid" do
    get calendar_meal_plan_path(@plan)
    assert_response :success
  end

  test "calendar for another user's plan returns not found" do
    other_plan = create(:meal_plan)
    get calendar_meal_plan_path(other_plan)
    assert_response :not_found
  end

  # ── generate ──────────────────────────────────────────────────────────────

  test "generate redirects to calendar on success" do
    create_list(:recipe, 5, meal_type: "breakfast")
    create_list(:recipe, 5, meal_type: "lunch")
    create_list(:recipe, 5, meal_type: "dinner")

    post generate_meal_plan_path(@plan)
    assert_redirected_to calendar_meal_plan_path(@plan)
  end

  test "generate responds with turbo stream" do
    create_list(:recipe, 5, meal_type: "breakfast")
    create_list(:recipe, 5, meal_type: "lunch")
    create_list(:recipe, 5, meal_type: "dinner")

    post generate_meal_plan_path(@plan),
         headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  # ── recipe_picker ─────────────────────────────────────────────────────────

  test "recipe_picker returns matching recipes for slot" do
    create(:recipe, name: "Scrambled Eggs", meal_type: "breakfast")
    create(:recipe, name: "Pasta", meal_type: "dinner")

    get recipe_picker_meal_plan_path(@plan), params: { slot: "breakfast", day: 0 }
    assert_response :success
    assert_match "Scrambled Eggs", response.body
    assert_no_match "Pasta", response.body
  end

  test "recipe_picker filters by search query" do
    create(:recipe, name: "Scrambled Eggs", meal_type: "breakfast")
    create(:recipe, name: "French Toast", meal_type: "breakfast")

    get recipe_picker_meal_plan_path(@plan), params: { slot: "breakfast", day: 0, q: "toast" }
    assert_response :success
    assert_match "French Toast", response.body
    assert_no_match "Scrambled Eggs", response.body
  end
end
