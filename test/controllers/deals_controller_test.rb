require "test_helper"

class DealsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user  = create(:user)
    @store = create(:store)
    UserStore.create!(user: @user, store: @store, primary: true)
    sign_in_as(@user)
  end

  test "index renders successfully with no deals" do
    get deals_path
    assert_response :success
  end

  test "index shows active deals" do
    create(:deal, store: @store, name: "Fresh Salmon")
    get deals_path
    assert_response :success
    assert_match "Fresh Salmon", response.body
  end

  test "index excludes expired deals" do
    create(:deal, :expired, store: @store, name: "Expired Item")
    get deals_path
    assert_no_match "Expired Item", response.body
  end

  test "index redirects unauthenticated users" do
    sign_out
    get deals_path
    assert_redirected_to new_session_path
  end

  test "show renders deal details" do
    deal = create(:deal, store: @store, name: "Organic Blueberries")
    get deal_path(deal)
    assert_response :success
    assert_match "Organic Blueberries", response.body
  end

  test "show redirects to index for deal from another store" do
    other_store = create(:store)
    deal = create(:deal, store: other_store)
    get deal_path(deal)
    assert_redirected_to deals_path
  end
end
