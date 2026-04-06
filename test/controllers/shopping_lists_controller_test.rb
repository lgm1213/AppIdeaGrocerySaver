require "test_helper"

class ShoppingListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
  end

  test "index shows user's lists" do
    list = create(:shopping_list, user: @user, name: "Weekly Groceries")
    get shopping_lists_path
    assert_response :success
    assert_match "Weekly Groceries", response.body
  end

  test "index does not show other users' lists" do
    other = create(:user)
    create(:shopping_list, user: other, name: "Other User List")
    get shopping_lists_path
    assert_no_match "Other User List", response.body
  end

  test "show renders list with items" do
    list = create(:shopping_list, user: @user)
    create(:shopping_list_item, shopping_list: list, name: "Avocado")
    get shopping_list_path(list)
    assert_response :success
    assert_match "Avocado", response.body
  end

  test "create with valid params redirects to list" do
    assert_difference("ShoppingList.count") do
      post shopping_lists_path, params: { shopping_list: { name: "Test List" } }
    end
    assert_redirected_to shopping_list_path(ShoppingList.last)
  end

  test "create with blank name re-renders form" do
    assert_no_difference("ShoppingList.count") do
      post shopping_lists_path, params: { shopping_list: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "destroy removes list and redirects" do
    list = create(:shopping_list, user: @user)
    assert_difference("ShoppingList.count", -1) do
      delete shopping_list_path(list)
    end
    assert_redirected_to shopping_lists_path
  end

  test "mark_complete updates list status" do
    list = create(:shopping_list, user: @user, status: "active")
    patch mark_complete_shopping_list_path(list)
    assert_equal "completed", list.reload.status
  end

  test "redirects unauthenticated users" do
    sign_out
    get shopping_lists_path
    assert_redirected_to new_session_path
  end
end
