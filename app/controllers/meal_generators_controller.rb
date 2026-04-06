class MealGeneratorsController < ApplicationController
  before_action :require_authentication
  before_action :require_onboarding_complete

  def new
    @preference = Current.user.user_preference
    @meal_slots  = MealPlan::MEAL_SLOTS
    @cuisines    = UserPreference::CUISINE_OPTIONS
    @dietary     = UserPreference::DIETARY_OPTIONS
  end

  def generate
    week_start = Date.parse(params[:week_start]) rescue MealPlan.current_week_start

    result = MealPlans::WeekBuilder.new(
      user:       Current.user,
      week_start: week_start,
      name:       "Generated Plan – #{week_start.strftime('%b %-d')}"
    ).call

    if result.success?
      redirect_to calendar_meal_plan_path(result.meal_plan),
                  notice: "Your meal plan is ready!"
    else
      @preference = Current.user.user_preference
      @meal_slots = MealPlan::MEAL_SLOTS
      @cuisines   = UserPreference::CUISINE_OPTIONS
      @dietary    = UserPreference::DIETARY_OPTIONS
      flash.now[:alert] = result.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def results; end
end
