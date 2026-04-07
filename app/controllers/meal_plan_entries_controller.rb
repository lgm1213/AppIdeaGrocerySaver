class MealPlanEntriesController < ApplicationController
  before_action :require_authentication
  before_action :set_meal_plan
  before_action :set_entry, only: %i[update destroy toggle_cooked]

  def create
    @entry = @meal_plan.meal_plan_entries.new(entry_params)

    if @entry.save
      @meal_plan.recalculate_cost!
      respond_to do |format|
        format.turbo_stream { render_slot_update }
        format.html { redirect_to calendar_meal_plan_path(@meal_plan) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash_messages",
            partial: "shared/flash",
            locals: { message: @entry.errors.full_messages.to_sentence, type: :alert }
          )
        end
        format.html { redirect_to calendar_meal_plan_path(@meal_plan), alert: @entry.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    if @entry.update(entry_params)
      @meal_plan.recalculate_cost!
      respond_to do |format|
        format.turbo_stream { render_slot_update }
        format.html { redirect_to calendar_meal_plan_path(@meal_plan) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash_messages",
            partial: "shared/flash",
            locals: { message: @entry.errors.full_messages.to_sentence, type: :alert }
          )
        end
        format.html { redirect_to calendar_meal_plan_path(@meal_plan), alert: @entry.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    day  = @entry.day_of_week
    slot = @entry.meal_slot
    @entry.destroy!
    @meal_plan.recalculate_cost!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          slot_frame_id(day, slot),
          partial: "meal_plans/empty_slot",
          locals: { meal_plan: @meal_plan, day: day, slot: slot }
        )
      end
      format.html { redirect_to calendar_meal_plan_path(@meal_plan) }
    end
  end

  def toggle_cooked
    if @entry.cooked?
      @entry.unmark_cooked!
    else
      @entry.mark_cooked!
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            slot_frame_id(@entry.day_of_week, @entry.meal_slot),
            partial: "meal_plans/slot_card",
            locals: { meal_plan: @meal_plan, entry: @entry }
          ),
          turbo_stream.replace(
            "dashboard_entry_#{@entry.id}",
            partial: "dashboard/today_meal_entry",
            locals: { entry: @entry, current_plan: @meal_plan }
          ),
          turbo_stream.replace(
            "dashboard_stats",
            partial: "dashboard/stats_strip",
            locals: dashboard_stats_locals
          )
        ]
      end
      format.html { redirect_to calendar_meal_plan_path(@meal_plan) }
    end
  end

  private

  def set_meal_plan
    @meal_plan = Current.user.meal_plans.find(params[:meal_plan_id])
  end

  def set_entry
    @entry = @meal_plan.meal_plan_entries.find(params[:id])
  end

  def entry_params
    params.require(:meal_plan_entry).permit(:recipe_id, :day_of_week, :meal_slot, :servings)
  end

  def render_slot_update
    render turbo_stream: turbo_stream.replace(
      slot_frame_id(@entry.day_of_week, @entry.meal_slot),
      partial: "meal_plans/slot_card",
      locals: { meal_plan: @meal_plan, entry: @entry }
    )
  end

  def slot_frame_id(day, slot)
    "slot_#{day}_#{slot}"
  end

  def dashboard_stats_locals
    user       = Current.user
    recipe_ids = @meal_plan.meal_plan_entries.filled.pluck(:recipe_id)
    savings    = Deal.savings_by_recipe(stores: user.stores, recipe_ids: recipe_ids).values.sum
    {
      planned_this_week:   @meal_plan.total_recipes,
      cooked_this_week:    @meal_plan.cooked_count,
      plans_count:         user.meal_plans.count,
      lists_count:         user.shopping_lists.count,
      weekly_deal_savings: savings > 0 ? format("$%.2f", savings) : "—"
    }
  end
end
