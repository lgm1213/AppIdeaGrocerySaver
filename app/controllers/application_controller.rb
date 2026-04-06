class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :resolve_layout

  private

  def resolve_layout
    if authenticated?
      return "onboarding" if Current.user && !Current.user.onboarding_complete?
      "app"
    else
      "application"
    end
  end

  def require_onboarding_complete
    return unless authenticated?
    return if Current.user.onboarding_complete?

    redirect_to onboarding_step_path, notice: "Please complete your profile first."
  end

  def onboarding_step_path
    case Current.user.onboarding_step
    when "preferences"     then onboarding_preferences_path
    when "budget_location" then onboarding_budget_location_path
    when "recap"           then onboarding_recap_path
    else onboarding_success_path
    end
  end
end
