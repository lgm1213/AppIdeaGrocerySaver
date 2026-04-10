require "test_helper"

class SendDealAlertsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  setup do
    @store      = create(:store)
    @ingredient = create(:ingredient)
    @recipe     = create(:recipe)
    RecipeIngredient.create!(recipe: @recipe, ingredient: @ingredient, quantity: 1, unit: "each")
  end

  test "enqueues one mailer per user who has relevant deals" do
    user = create(:user)
    user.stores << @store
    create(:user_recipe_preference, user: user, recipe: @recipe, liked: true)
    create(:deal, :matched, store: @store, ingredient: @ingredient)

    assert_enqueued_emails 1 do
      SendDealAlertsJob.perform_now
    end
  end

  test "does not enqueue mailer for users with no relevant deals" do
    user = create(:user)
    user.stores << @store
    # User has no preferences → no digest

    assert_no_enqueued_emails do
      SendDealAlertsJob.perform_now
    end
  end

  test "does not enqueue mailer when user's stores have no active deals" do
    user = create(:user)
    user.stores << @store
    create(:user_recipe_preference, user: user, recipe: @recipe, liked: true)
    create(:deal, :matched, :expired, store: @store, ingredient: @ingredient)

    assert_no_enqueued_emails do
      SendDealAlertsJob.perform_now
    end
  end

  test "enqueues separate mailers for multiple qualifying users" do
    2.times do
      user = create(:user)
      user.stores << @store
      create(:user_recipe_preference, user: user, recipe: @recipe, liked: true)
    end
    create(:deal, :matched, store: @store, ingredient: @ingredient)

    assert_enqueued_emails 2 do
      SendDealAlertsJob.perform_now
    end
  end
end
