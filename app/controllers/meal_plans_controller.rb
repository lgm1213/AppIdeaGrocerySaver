class MealPlansController < ApplicationController
  before_action :require_authentication
  before_action :require_onboarding_complete
  before_action :set_meal_plan, only: %i[show edit update destroy calendar generate recipe_picker]

  def index
    @meal_plans = Current.user.meal_plans.recent
    @current_plan = @meal_plans.active.for_week(Date.current).first
  end

  def show
    redirect_to calendar_meal_plan_path(@meal_plan)
  end

  def new
    @meal_plan = Current.user.meal_plans.new(
      week_start_date: MealPlan.current_week_start,
      name: "Week of #{MealPlan.current_week_start.strftime('%b %-d, %Y')}"
    )
  end

  def create
    @meal_plan = Current.user.meal_plans.new(meal_plan_params)

    if @meal_plan.save
      redirect_to calendar_meal_plan_path(@meal_plan), notice: "Meal plan created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @meal_plan.update(meal_plan_params)
      redirect_to calendar_meal_plan_path(@meal_plan), notice: "Plan updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meal_plan.destroy!
    redirect_to meal_plans_path, notice: "Plan deleted."
  end

  def calendar
    @grid         = @meal_plan.grid
    @days         = MealPlan::DAYS
    @meal_slots   = MealPlan::MEAL_SLOTS
    @deal_savings = load_deal_savings(@meal_plan)
  end

  def generate
    result = MealPlans::WeekBuilder.new(
      user:       Current.user,
      week_start: @meal_plan.week_start_date,
      name:       @meal_plan.name
    ).call

    if result.success?
      respond_to do |format|
        format.html { redirect_to calendar_meal_plan_path(@meal_plan), notice: "Plan generated!" }
        format.turbo_stream do
          @meal_plan.reload
          @grid         = @meal_plan.grid
          @days         = MealPlan::DAYS
          @meal_slots   = MealPlan::MEAL_SLOTS
          @deal_savings = load_deal_savings(@meal_plan)
          render turbo_stream: turbo_stream.replace(
            "meal_plan_calendar",
            partial: "meal_plans/calendar_grid",
            locals: { meal_plan: @meal_plan, grid: @grid, days: @days, meal_slots: @meal_slots, deal_savings: @deal_savings }
          )
        end
      end
    else
      redirect_to calendar_meal_plan_path(@meal_plan),
                  alert: result.errors.full_messages.to_sentence
    end
  end

  def recipe_picker
    slot  = params[:slot]
    day   = params[:day].to_i
    query = params[:q].to_s.strip

    @recipes = Recipe.for_meal(slot)
    @recipes = @recipes.matching_preferences(Current.user.user_preference)
    @recipes = @recipes.where("name ILIKE ?", "%#{query}%") if query.present?
    @recipes = @recipes.order(:name).limit(30)

    render partial: "meal_plans/recipe_picker_list",
           locals: {
             recipes:   @recipes,
             meal_plan: @meal_plan,
             day:       day,
             slot:      slot,
             entry_id:  params[:entry_id]
           }
  end

  private

  def set_meal_plan
    @meal_plan = Current.user.meal_plans.find(params[:id])
  end

  def load_deal_savings(meal_plan)
    recipe_ids = meal_plan.meal_plan_entries.filled.pluck(:recipe_id)
    Deal.savings_by_recipe(stores: Current.user.stores, recipe_ids: recipe_ids)
  end

  def meal_plan_params
    params.require(:meal_plan).permit(:name, :week_start_date)
  end
end
