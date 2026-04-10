require "test_helper"

class Deals::AlertDigestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  setup do
    @store      = create(:store)
    @user       = create(:user)
    @user.stores << @store

    @ingredient = create(:ingredient)
    @recipe     = create(:recipe)
    RecipeIngredient.create!(recipe: @recipe, ingredient: @ingredient, quantity: 1, unit: "each")
  end

  # ── relevant? ──────────────────────────────────────────────────────────────

  test "relevant? is false when user has no liked or rated recipes" do
    digest = Deals::AlertDigest.new(@user)
    assert_not digest.relevant?
  end

  test "relevant? is false when liked recipes have no active deals" do
    create(:user_recipe_preference, user: @user, recipe: @recipe, liked: true)
    # No deal created — no match

    digest = Deals::AlertDigest.new(@user)
    assert_not digest.relevant?
  end

  test "relevant? is true when liked recipe has an active matched deal" do
    create(:user_recipe_preference, user: @user, recipe: @recipe, liked: true)
    create(:deal, :matched, store: @store, ingredient: @ingredient)

    digest = Deals::AlertDigest.new(@user)
    assert digest.relevant?
  end

  test "relevant? is true when rated (not liked) recipe has an active matched deal" do
    create(:user_recipe_preference, user: @user, recipe: @recipe, liked: nil, rating: 4)
    create(:deal, :matched, store: @store, ingredient: @ingredient)

    digest = Deals::AlertDigest.new(@user)
    assert digest.relevant?
  end

  test "relevant? is false when deal is expired" do
    create(:user_recipe_preference, user: @user, recipe: @recipe, liked: true)
    create(:deal, :matched, :expired, store: @store, ingredient: @ingredient)

    digest = Deals::AlertDigest.new(@user)
    assert_not digest.relevant?
  end

  test "relevant? is false when deal is for a different store" do
    other_store = create(:store)
    create(:user_recipe_preference, user: @user, recipe: @recipe, liked: true)
    create(:deal, :matched, store: other_store, ingredient: @ingredient)

    digest = Deals::AlertDigest.new(@user)
    assert_not digest.relevant?
  end

  # ── deals ──────────────────────────────────────────────────────────────────

  test "deals returns matched active deals for user's liked recipes" do
    create(:user_recipe_preference, user: @user, recipe: @recipe, liked: true)
    deal = create(:deal, :matched, store: @store, ingredient: @ingredient)

    digest = Deals::AlertDigest.new(@user)
    assert_includes digest.deals, deal
  end

  test "deals does not include deals for unliked/unrated recipes" do
    other_recipe    = create(:recipe)
    other_ingredient = create(:ingredient)
    RecipeIngredient.create!(recipe: other_recipe, ingredient: other_ingredient, quantity: 1, unit: "each")
    create(:deal, :matched, store: @store, ingredient: other_ingredient)
    # @user has no preference for other_recipe

    digest = Deals::AlertDigest.new(@user)
    assert_empty digest.deals
  end

  # ── deliver ────────────────────────────────────────────────────────────────

  test "deliver enqueues mailer when digest is relevant" do
    create(:user_recipe_preference, user: @user, recipe: @recipe, liked: true)
    create(:deal, :matched, store: @store, ingredient: @ingredient)

    digest = Deals::AlertDigest.new(@user)

    assert_enqueued_emails 1 do
      result = digest.deliver
      assert result
    end
  end

  test "deliver returns false and sends no email when not relevant" do
    digest = Deals::AlertDigest.new(@user)

    assert_no_enqueued_emails do
      result = digest.deliver
      assert_not result
    end
  end
end
