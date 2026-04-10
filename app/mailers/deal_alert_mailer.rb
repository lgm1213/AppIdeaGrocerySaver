class DealAlertMailer < ApplicationMailer
  def digest(user, deals)
    @user  = user
    @deals = deals

    mail(
      to:      user.email_address,
      subject: "#{deals.size} deal#{'s' if deals.size != 1} this week on ingredients you love!"
    )
  end
end
