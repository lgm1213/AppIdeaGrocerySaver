require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin  = create(:user, admin: true)
    @target = create(:user, admin: false)
  end

  # ── auth gate ──────────────────────────────────────────────────────────────

  test "index redirects unauthenticated users" do
    get admin_users_path
    assert_redirected_to new_session_path
  end

  test "index redirects non-admin users" do
    sign_in_as(@target)
    get admin_users_path
    assert_redirected_to dashboard_path
  end

  # ── index ──────────────────────────────────────────────────────────────────

  test "index renders user list for admin" do
    sign_in_as(@admin)
    get admin_users_path
    assert_response :success
    assert_match @target.email_address, response.body
  end

  # ── show ───────────────────────────────────────────────────────────────────

  test "show renders user detail for admin" do
    sign_in_as(@admin)
    get admin_user_path(@target)
    assert_response :success
    assert_match @target.email_address, response.body
  end

  test "show redirects non-admin" do
    sign_in_as(@target)
    get admin_user_path(@admin)
    assert_redirected_to dashboard_path
  end

  # ── toggle_admin ───────────────────────────────────────────────────────────

  test "toggle_admin grants admin to a regular user" do
    sign_in_as(@admin)
    assert_not @target.admin?

    patch toggle_admin_admin_user_path(@target)

    assert @target.reload.admin?
    assert_redirected_to admin_user_path(@target)
    assert_match "granted", flash[:notice]
  end

  test "toggle_admin revokes admin from an admin user" do
    other_admin = create(:user, admin: true)
    sign_in_as(@admin)

    patch toggle_admin_admin_user_path(other_admin)

    assert_not other_admin.reload.admin?
    assert_redirected_to admin_user_path(other_admin)
    assert_match "revoked", flash[:notice]
  end

  test "toggle_admin returns bad request when targeting own account" do
    sign_in_as(@admin)
    patch toggle_admin_admin_user_path(@admin)
    assert_response :bad_request
  end

  # ── reset_onboarding ───────────────────────────────────────────────────────

  test "reset_onboarding resets user onboarding state" do
    sign_in_as(@admin)

    patch reset_onboarding_admin_user_path(@target)

    @target.reload
    assert_not @target.onboarding_complete
    assert_equal "preferences", @target.onboarding_step
    assert_redirected_to admin_user_path(@target)
    assert_match "reset", flash[:notice]
  end
end
