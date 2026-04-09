module MealPlans
  module Providers
    # Picks recipes whose ingredients have the most active deal savings this week,
    # weighted by the user's personal preferences and community ratings.
    #
    # Scoring (higher = more likely to be suggested):
    #   deal_score        — sum of COALESCE(savings_amount, 5.0) for on-sale ingredients
    #   preference_boost  — +15 if user has liked this recipe
    #   community_weight  — average_rating * 3 (0–15 bonus points)
    #
    # Blocked recipes (liked = false) are excluded entirely.
    class DealAwareProvider
      SLOTS                = MealPlan::MEAL_SLOTS
      TOP_N                = 5
      BOGO_SAVINGS_DEFAULT = 5.0
      PREFERENCE_BOOST     = 15.0
      COMMUNITY_WEIGHT     = 3.0

      def suggested_entries(plan:, preferences:, user: nil)
        @savings_by_ingredient = load_savings_map
        @user_prefs            = load_user_prefs(user)
        @blocked_recipe_ids    = @user_prefs.select { |_, p| p.liked == false }.keys.to_set
        @used_recipe_ids       = Set.new(plan.meal_plan_entries.filled.pluck(:recipe_id))

        entries = []

        (0..6).each do |day|
          active_slots(preferences).each do |slot|
            next if slot_already_filled?(plan, day, slot)

            recipe = pick_recipe(slot, preferences)
            next unless recipe

            @used_recipe_ids << recipe.id
            entries << {
              day_of_week: day,
              meal_slot:   slot,
              recipe_id:   recipe.id,
              servings:    preferences&.household_size || 2
            }
          end
        end

        entries
      end

      private

      # recipe_id => UserRecipePreference
      def load_user_prefs(user)
        return {} unless user

        user.user_recipe_preferences.index_by(&:recipe_id)
      end

      def load_savings_map
        Deal.active.matched
            .group(:ingredient_id)
            .sum("COALESCE(savings_amount, #{BOGO_SAVINGS_DEFAULT})")
      end

      def score(recipe)
        deal    = recipe.recipe_ingredients.sum { |ri| @savings_by_ingredient[ri.ingredient_id] || 0 }
        pref    = @user_prefs[recipe.id]
        boost   = pref&.liked == true ? PREFERENCE_BOOST : 0.0
        community = (recipe.average_rating || 0).to_f * COMMUNITY_WEIGHT

        deal + boost + community
      end

      def pick_recipe(slot, preferences)
        candidates = Recipe.for_meal(slot)
                           .matching_preferences(preferences)
                           .where.not(id: @used_recipe_ids)
                           .where.not(id: @blocked_recipe_ids)
                           .includes(:recipe_ingredients)
                           .to_a

        return nil if candidates.empty?

        scored   = candidates.map { |r| [ r, score(r) ] }.sort_by { |_, s| -s }
        top_pool = scored.first(TOP_N)
        top_pool.sample.first
      end

      def active_slots(preferences)
        return SLOTS unless preferences

        SLOTS.select do |slot|
          case slot
          when "breakfast" then preferences.include_breakfast
          when "lunch"     then preferences.include_lunch
          when "dinner"    then preferences.include_dinner
          end
        end
      end

      def slot_already_filled?(plan, day, slot)
        plan.meal_plan_entries.filled.exists?(day_of_week: day, meal_slot: slot)
      end
    end
  end
end
