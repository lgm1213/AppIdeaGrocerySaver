class DealAlertMailer < ApplicationMailer
  def digest(user, deals)
    @user  = user
    @deals = deals
    @unsubscribe_url = unsubscribe_url(user.unsubscribe_token)

    mail(
      to:      user.email_address,
      subject: "#{deals.size} deal#{'s' if deals.size != 1} this week on ingredients you love!",
      "List-Unsubscribe"      => "<#{@unsubscribe_url}>",
      "List-Unsubscribe-Post" => "List-Unsubscribe=One-Click"
    )
  end
end
