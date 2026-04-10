require "test_helper"

class Admin::JobExecutionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, admin: true)
    @user  = create(:user, admin: false)
  end

  def create_sq_job
    SolidQueue::Job.create!(
      queue_name: "default",
      class_name: "FetchDealsJob",
      arguments:  { "job_class" => "FetchDealsJob", "arguments" => [] }.to_json,
      priority:   0
    )
  end

  # ── auth gate ──────────────────────────────────────────────────────────────

  test "index redirects unauthenticated users" do
    get admin_job_executions_path
    assert_redirected_to new_session_path
  end

  test "index redirects non-admin users" do
    sign_in_as(@user)
    get admin_job_executions_path
    assert_redirected_to dashboard_path
  end

  # ── index ──────────────────────────────────────────────────────────────────

  test "index renders with default (all) filter for admin" do
    sign_in_as(@admin)
    get admin_job_executions_path
    assert_response :success
  end

  test "index renders with failed status filter" do
    sign_in_as(@admin)
    get admin_job_executions_path, params: { status: "failed" }
    assert_response :success
  end

  test "index renders with completed status filter" do
    sign_in_as(@admin)
    get admin_job_executions_path, params: { status: "completed" }
    assert_response :success
  end

  # ── show ───────────────────────────────────────────────────────────────────

  test "show renders job detail for admin" do
    sq_job = create_sq_job
    sign_in_as(@admin)

    get admin_job_execution_path(sq_job)

    assert_response :success
    assert_match "FetchDealsJob", response.body
  end

  test "show redirects non-admin" do
    sq_job = create_sq_job
    sign_in_as(@user)
    get admin_job_execution_path(sq_job)
    assert_redirected_to dashboard_path
  end

  # ── destroy ────────────────────────────────────────────────────────────────

  test "destroy removes the job and redirects" do
    sq_job = create_sq_job
    sign_in_as(@admin)

    assert_difference("SolidQueue::Job.count", -1) do
      delete admin_job_execution_path(sq_job)
    end

    assert_redirected_to admin_job_executions_path
    assert_match "discarded", flash[:notice]
  end

  test "destroy redirects non-admin" do
    sq_job = create_sq_job
    sign_in_as(@user)
    delete admin_job_execution_path(sq_job)
    assert_redirected_to dashboard_path
  end
end
