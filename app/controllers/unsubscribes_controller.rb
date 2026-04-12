class UnsubscribesController < ApplicationController
  # No authentication required — the token in the URL is the auth.
  skip_before_action :require_authentication
  layout false

  before_action :find_user_by_token

  # GET /unsubscribe/:token
  # Shows a confirmation page before opting the user out.
  def show
  end

  # POST /unsubscribe/:token
  # Opts the user out of deal alert emails.
  def update
    pref = @user.user_preference
    if pref&.update(email_deal_alerts: false)
      redirect_to unsubscribe_path(params[:token]), notice: "unsubscribed"
    else
      redirect_to unsubscribe_path(params[:token]), alert: "Something went wrong. Please try again."
    end
  end

  private

  def find_user_by_token
    @user = User.find_by(unsubscribe_token: params[:token])
    render file: "public/404.html", status: :not_found, layout: false unless @user
  end
end
