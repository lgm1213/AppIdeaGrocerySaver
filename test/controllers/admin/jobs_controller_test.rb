require "test_helper"

class Admin::JobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, admin: true)
    @user  = create(:user, admin: false)
  end

  # ── auth gate ──────────────────────────────────────────────────────────────

  test "index redirects unauthenticated users" do
    get admin_jobs_path
    assert_redirected_to new_session_path
  end

  test "index redirects non-admin users" do
    sign_in_as(@user)
    get admin_jobs_path
    assert_redirected_to dashboard_path
  end

  # ── index ──────────────────────────────────────────────────────────────────

  test "index renders job list for admin" do
    sign_in_as(@admin)
    get admin_jobs_path
    assert_response :success
    assert_match "Fetch Publix Deals", response.body
  end

  # ── status ─────────────────────────────────────────────────────────────────

  test "status renders without layout for admin" do
    sign_in_as(@admin)
    get status_admin_jobs_path
    assert_response :success
  end

  test "status redirects non-admin" do
    sign_in_as(@user)
    get status_admin_jobs_path
    assert_redirected_to dashboard_path
  end

  # ── create ─────────────────────────────────────────────────────────────────

  test "create enqueues a known job and redirects with notice" do
    sign_in_as(@admin)

    assert_enqueued_with(job: FetchDealsJob) do
      post admin_jobs_path, params: { job_key: "fetch_deals" }
    end

    assert_redirected_to admin_jobs_path
    assert_match "enqueued", flash[:notice]
  end

  test "create with unknown job key redirects with alert" do
    sign_in_as(@admin)

    post admin_jobs_path, params: { job_key: "nonexistent_job" }

    assert_redirected_to admin_jobs_path
    assert_match "Unknown job", flash[:alert]
  end

  test "create redirects non-admin" do
    sign_in_as(@user)
    post admin_jobs_path, params: { job_key: "fetch_deals" }
    assert_redirected_to dashboard_path
  end
end
