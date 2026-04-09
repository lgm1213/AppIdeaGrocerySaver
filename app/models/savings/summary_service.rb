module Savings
  class SummaryService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    # Deal savings for the current week's meal plan (uses live active deals).
    def this_week_deal_savings
      @this_week_deal_savings ||= begin
        plan = current_week_plan
        return 0.0 unless plan

        recipe_ids = plan.meal_plan_entries.filled.pluck(:recipe_id)
        return 0.0 if recipe_ids.empty?

        Deal.savings_by_recipe(stores: user.stores, recipe_ids: recipe_ids)
            .values.sum.round(2)
      end
    end

    # Total estimated spend summed across all meal plans.
    def total_estimated_spend
      @total_estimated_spend ||= user.meal_plans.sum(:total_estimated_cost).to_f.round(2)
    end

    # Average weekly cost across plans that have a cost recorded.
    def average_weekly_cost
      @average_weekly_cost ||= begin
        avg = user.meal_plans.where.not(total_estimated_cost: nil).average(:total_estimated_cost)
        avg&.to_f&.round(2) || 0.0
      end
    end

    # Total filled meal plan entries across all time.
    def total_meals_planned
      @total_meals_planned ||= all_entries.filled.count
    end

    # Total meals marked cooked across all time.
    def total_meals_cooked
      @total_meals_cooked ||= all_entries.where(cooked: true).count
    end

    # Percentage of planned meals that were cooked (0–100).
    def cooking_efficiency
      return 0 if total_meals_planned.zero?
      (total_meals_cooked.to_f / total_meals_planned * 100).round
    end

    # Average cost as a percentage of the weekly budget (nil if no budget set).
    def budget_utilization
      budget = user.user_preference&.weekly_budget.to_f
      return nil if budget.zero? || average_weekly_cost.zero?

      (average_weekly_cost / budget * 100).round
    end

    # How many weeks the user stayed under budget.
    def weeks_under_budget
      budget = user.user_preference&.weekly_budget.to_f
      return 0 if budget.zero?

      user.meal_plans
          .where.not(total_estimated_cost: nil)
          .where("total_estimated_cost <= ?", budget)
          .count
    end

    def plans_count
      @plans_count ||= user.meal_plans.count
    end

    # Last N weeks of meal plan data for the spend chart.
    # Returns an array of hashes ordered oldest → newest.
    def weekly_data(weeks: 8)
      start  = weeks.weeks.ago.beginning_of_week(:monday).to_date
      budget = user.user_preference&.weekly_budget.to_f

      user.meal_plans
          .where(week_start_date: start..)
          .order(week_start_date: :asc)
          .map do |plan|
            {
              week_label:     plan.week_label,
              week_start:     plan.week_start_date,
              estimated_cost: plan.total_estimated_cost&.to_f || 0.0,
              budget:         budget,
              cooked:         plan.cooked_count,
              planned:        plan.total_recipes,
              current:        plan.current_week?
            }
          end
    end

    def current_week_plan
      @current_week_plan ||= user.meal_plans.active.for_week(Date.current).first
    end

    private

    def all_entries
      MealPlanEntry.joins(:meal_plan).where(meal_plans: { user_id: user.id })
    end
  end
end
