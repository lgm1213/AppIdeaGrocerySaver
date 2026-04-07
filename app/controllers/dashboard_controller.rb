class DashboardController < ApplicationController
  before_action :require_authentication
  before_action :require_onboarding_complete

  def index
    user = Current.user
    pref = user.user_preference

    # Current week plan
    @current_plan = user.meal_plans.active.for_week(Date.current).first

    # Today's entries
    if @current_plan
      today_offset  = (Date.current - @current_plan.week_start_date).to_i
      @today_entries = @current_plan.meal_plan_entries
        .includes(:recipe)
        .where(day_of_week: today_offset)
        .order(Arel.sql("CASE meal_slot WHEN 'breakfast' THEN 0 WHEN 'lunch' THEN 1 WHEN 'dinner' THEN 2 END"))
    else
      @today_entries = []
    end

    # Budget data
    @weekly_budget  = pref&.weekly_budget
    @spent_estimate = @current_plan&.total_estimated_cost

    # Active shopping list
    @active_list = user.shopping_lists.active.order(created_at: :desc).first

    # Recent plans (excluding current)
    @recent_plans = user.meal_plans.recent.limit(4).to_a

    # Deals preview (top 3 active deals from user's stores)
    @deal_previews = top_deals(user)

    # Stats
    @plans_count       = user.meal_plans.count
    @lists_count       = user.shopping_lists.count
    @cooked_this_week  = @current_plan&.cooked_count || 0
    @planned_this_week = @current_plan&.total_recipes || 0

    # Potential savings this week from deals matching the current plan's recipes
    total = weekly_deal_savings_total(user)
    @weekly_deal_savings = total > 0 ? format("$%.2f", total) : "—"
  end

  private

  def top_deals(user)
    stores = user.stores
    return [] if stores.empty?

    Deal.for_user_stores(stores).active.order(savings_amount: :desc).limit(3)
  end

  def weekly_deal_savings_total(user)
    return 0 unless @current_plan

    recipe_ids = @current_plan.meal_plan_entries.filled.pluck(:recipe_id)
    return 0 if recipe_ids.empty?

    Deal.savings_by_recipe(stores: user.stores, recipe_ids: recipe_ids).values.sum
  end
end
