require "test_helper"

class Admin::EmailSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, admin: true)
    @user  = create(:user, admin: false)
  end

  # ── auth gate ──────────────────────────────────────────────────────────────

  test "show redirects unauthenticated users" do
    get admin_email_settings_path
    assert_redirected_to new_session_path
  end

  test "show redirects non-admin users" do
    sign_in_as(@user)
    get admin_email_settings_path
    assert_redirected_to dashboard_path
  end

  # ── show ───────────────────────────────────────────────────────────────────

  test "show renders settings page for admin" do
    sign_in_as(@admin)
    get admin_email_settings_path
    assert_response :success
  end

  # ── edit ───────────────────────────────────────────────────────────────────

  test "edit renders form for admin" do
    sign_in_as(@admin)
    get edit_admin_email_settings_path
    assert_response :success
    assert_match "smtp_address", response.body
  end

  test "edit redirects non-admin" do
    sign_in_as(@user)
    get edit_admin_email_settings_path
    assert_redirected_to dashboard_path
  end

  # ── update ─────────────────────────────────────────────────────────────────

  test "update saves smtp settings and redirects with notice" do
    sign_in_as(@admin)

    patch admin_email_settings_path, params: {
      email_settings: {
        smtp_address:      "smtp.example.com",
        smtp_port:         "587",
        smtp_domain:       "example.com",
        smtp_username:     "user@example.com",
        smtp_password:     "secret",
        smtp_from_address: "noreply@example.com"
      }
    }

    assert_redirected_to admin_email_settings_path
    assert_match "saved", flash[:notice]
    assert_equal "smtp.example.com", SystemSetting[:smtp_address]
    assert_equal "587",              SystemSetting[:smtp_port]
  end

  test "update does not overwrite password when field is blank" do
    SystemSetting[:smtp_password] = "original_password"
    sign_in_as(@admin)

    patch admin_email_settings_path, params: {
      email_settings: { smtp_address: "smtp.example.com", smtp_password: "" }
    }

    assert_equal "original_password", SystemSetting[:smtp_password]
  end

  test "update redirects non-admin" do
    sign_in_as(@user)
    patch admin_email_settings_path, params: { email_settings: { smtp_address: "x" } }
    assert_redirected_to dashboard_path
  end
end
