class OmniauthCallbacksController < ApplicationController
  skip_before_action :require_authentication
  allow_unauthenticated_access

  def create
    user = User.find_or_create_from_omniauth(request.env["omniauth.auth"])
    start_new_session_for(user)

    if user.onboarding_complete?
      redirect_to dashboard_path, notice: "Signed in successfully."
    else
      redirect_to onboarding_preferences_path, notice: "Welcome! Let's get you set up."
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("OmniAuth sign-in failed: #{e.message}")
    redirect_to new_session_path, alert: "Sign in failed. Please try again."
  end

  def failure
    redirect_to new_session_path, alert: "Sign in was cancelled or failed. Please try again."
  end
end
