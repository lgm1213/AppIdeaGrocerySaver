class WelcomeMailer < ApplicationMailer
  def welcome(user)
    @user = user

    mail(
      to:      user.email_address,
      subject: "Welcome to Save & Savor!"
    )
  end
end
