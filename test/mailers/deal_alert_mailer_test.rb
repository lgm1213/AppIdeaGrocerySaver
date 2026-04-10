require "test_helper"

class DealAlertMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers
  setup do
    @user       = create(:user)
    @store      = create(:store)
    @ingredient = create(:ingredient, name: "Chicken Breast")
    @deal       = create(:deal, :matched, store: @store, ingredient: @ingredient,
                          name: "Fresh Chicken Breast", savings_amount: 2.50)
  end

  test "digest is sent to the correct recipient" do
    mail = DealAlertMailer.digest(@user, [ @deal ])
    assert_equal [ @user.email_address ], mail.to
  end

  test "digest subject reflects deal count" do
    mail = DealAlertMailer.digest(@user, [ @deal ])
    assert_match "1 deal", mail.subject
  end

  test "digest subject pluralises for multiple deals" do
    deal2 = create(:deal, :matched, store: @store, ingredient: create(:ingredient))
    mail  = DealAlertMailer.digest(@user, [ @deal, deal2 ])
    assert_match "2 deals", mail.subject
  end

  test "digest HTML body includes deal name" do
    mail = DealAlertMailer.digest(@user, [ @deal ])
    assert_match "Fresh Chicken Breast", mail.html_part.body.to_s
  end

  test "digest HTML body includes ingredient name" do
    mail = DealAlertMailer.digest(@user, [ @deal ])
    assert_match "Chicken Breast", mail.html_part.body.to_s
  end

  test "digest text body includes deal name" do
    mail = DealAlertMailer.digest(@user, [ @deal ])
    assert_match "Fresh Chicken Breast", mail.text_part.body.to_s
  end

  test "digest HTML body includes link to deals page" do
    mail = DealAlertMailer.digest(@user, [ @deal ])
    assert_match "/app/deals", mail.html_part.body.to_s
  end
end
