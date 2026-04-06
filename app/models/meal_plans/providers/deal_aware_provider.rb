module MealPlans
  module Providers
    # Picks recipes whose ingredients have the most active deal savings this week.
    # Scores each candidate recipe by summing savings_amount across all its
    # ingredients that currently have a matched deal. Falls back to random
    # selection when no deals are present.
    class DealAwareProvider
      SLOTS       = MealPlan::MEAL_SLOTS
      TOP_N       = 5   # candidate pool size per slot pick

      def suggested_entries(plan:, preferences:)
        @savings_by_ingredient = load_savings_map
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

      # ingredient_id => total savings this week (aggregated across all deals).
      # BOGO deals without a parsed savings_amount default to BOGO_SAVINGS_DEFAULT
      # so they still contribute to the score.
      BOGO_SAVINGS_DEFAULT = 5.0

      def load_savings_map
        Deal.active.matched
            .group(:ingredient_id)
            .sum("COALESCE(savings_amount, #{BOGO_SAVINGS_DEFAULT})")
      end

      def deal_score(recipe)
        ingredient_ids = recipe.recipe_ingredients.pluck(:ingredient_id)
        ingredient_ids.sum { |id| @savings_by_ingredient[id] || 0 }
      end

      def pick_recipe(slot, preferences)
        candidates = Recipe.for_meal(slot)
                           .matching_preferences(preferences)
                           .where.not(id: @used_recipe_ids)
                           .includes(:recipe_ingredients)
                           .to_a

        return nil if candidates.empty?

        scored = candidates.map { |r| [ r, deal_score(r) ] }
                           .sort_by { |_, score| -score }

        # Prefer recipes with deal savings; fall back to full pool if none
        with_savings = scored.select { |_, score| score > 0 }
        pool         = with_savings.any? ? with_savings.first(TOP_N) : scored.first(TOP_N)

        pool.sample.first
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
