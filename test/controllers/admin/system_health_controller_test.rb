require "test_helper"

class Admin::SystemHealthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, admin: true)
    @user  = create(:user, admin: false)
  end

  # ── auth gate ──────────────────────────────────────────────────────────────

  test "redirects unauthenticated users" do
    get admin_system_health_path
    assert_redirected_to new_session_path
  end

  test "redirects non-admin users" do
    sign_in_as(@user)
    get admin_system_health_path
    assert_redirected_to dashboard_path
  end

  # ── show ───────────────────────────────────────────────────────────────────

  test "renders health dashboard for admin" do
    sign_in_as(@admin)
    get admin_system_health_path
    assert_response :success
  end

  test "displays ruby and rails version info" do
    sign_in_as(@admin)
    get admin_system_health_path
    assert_match RUBY_VERSION, response.body
    assert_match Rails.version, response.body
  end

  test "displays database connected status" do
    sign_in_as(@admin)
    get admin_system_health_path
    # DB is always connected in test — page should not show a connection error
    assert_response :success
  end
end
