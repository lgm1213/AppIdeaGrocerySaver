module Deals
  class AlertDigest
    attr_reader :user, :deals

    def initialize(user)
      @user  = user
      @deals = find_relevant_deals
    end

    def relevant?
      deals.any?
    end

    def deliver
      return false unless relevant?
      return false unless user.user_preference&.email_deal_alerts != false

      DealAlertMailer.digest(user, deals.to_a).deliver_later
      true
    end

    private

    def find_relevant_deals
      ingredient_ids = RecipeIngredient
        .where(recipe_id: liked_or_rated_recipe_ids)
        .pluck(:ingredient_id)
        .uniq

      return [] if ingredient_ids.empty?

      Deal
        .active
        .matched
        .for_user_stores(user.stores)
        .where(ingredient_id: ingredient_ids)
        .includes(:ingredient, :store)
        .order(:name)
    end

    def liked_or_rated_recipe_ids
      prefs = user.user_recipe_preferences
      prefs.liked.or(prefs.rated).pluck(:recipe_id)
    end
  end
end
