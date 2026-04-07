class NotificationsController < ApplicationController
  before_action :require_authentication

  def dismiss_deals
    Current.user.user_preference&.update!(deals_last_seen_at: Time.current)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("deals_notification_banner") }
      format.html         { redirect_back_or_to dashboard_path }
    end
  end
end
