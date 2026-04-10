require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, admin: true)
    @user  = create(:user, admin: false)
  end

  # ── auth gate ──────────────────────────────────────────────────────────────

  test "redirects unauthenticated users" do
    get admin_root_path
    assert_redirected_to new_session_path
  end

  test "redirects non-admin users with alert" do
    sign_in_as(@user)
    get admin_root_path
    assert_redirected_to dashboard_path
    assert_equal "Access denied.", flash[:alert]
  end

  # ── index ──────────────────────────────────────────────────────────────────

  test "renders successfully for admin" do
    sign_in_as(@admin)
    get admin_root_path
    assert_response :success
  end
end
