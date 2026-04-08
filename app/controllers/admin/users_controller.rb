module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :toggle_admin, :reset_onboarding ]

    def index
      @users = User.includes(:user_preference, :user_stores)
                   .order(created_at: :desc)
    end

    def show
      @sessions = @user.sessions.order(created_at: :desc).limit(10)
    end

    def toggle_admin
      raise ActionController::BadRequest, "Cannot change your own admin status" if @user == Current.user

      @user.update!(admin: !@user.admin?)
      state = @user.admin? ? "granted" : "revoked"
      redirect_to admin_user_path(@user), notice: "Admin access #{state} for #{@user.email_address}."
    end

    def reset_onboarding
      @user.update!(onboarding_complete: false, onboarding_step: "preferences")
      redirect_to admin_user_path(@user), notice: "Onboarding reset for #{@user.email_address}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
