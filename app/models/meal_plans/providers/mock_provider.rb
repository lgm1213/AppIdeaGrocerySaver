module MealPlans
  module Providers
    # Returns random recipes matching user preferences for each unfilled slot.
    # Satisfies the provider interface — swap with AiProvider when ready.
    class MockProvider
      SLOTS = MealPlan::MEAL_SLOTS

      def suggested_entries(plan:, preferences:)
        entries = []

        (0..6).each do |day|
          active_slots(preferences).each do |slot|
            next if slot_already_filled?(plan, day, slot)

            recipe = pick_recipe(slot, preferences)
            next unless recipe

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

      def pick_recipe(slot, preferences)
        scope = Recipe.for_meal(slot).matching_preferences(preferences)
        scope = scope.order(Arel.sql("RANDOM()"))
        scope.first
      end
    end
  end
end
