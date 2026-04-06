class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  layout "application"

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to onboarding_preferences_path, notice: "Welcome to Save & Savor! Let's get you set up."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
