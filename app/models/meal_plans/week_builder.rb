module MealPlans
  # Builds a full week of meal plan entries from user preferences.
  # Provider is selected via Rails.application.config.meal_ai_provider.
  # Default: "deals" — ranks recipes by active Publix deal savings.
  # Fallback: "mock" — random selection regardless of deals.
  #
  #   result = MealPlans::WeekBuilder.new(user: current_user).call
  #   result.meal_plan   # => MealPlan
  #   result.errors      # => []
  #
  class WeekBuilder
    include ActiveModel::Model

    attr_reader :meal_plan, :errors

    PROVIDER_MAP = {
      "deals" => MealPlans::Providers::DealAwareProvider,
      "mock"  => MealPlans::Providers::MockProvider
    }.freeze

    def initialize(user:, week_start: nil, name: nil)
      @user        = user
      @week_start  = week_start || MealPlan.current_week_start
      @name        = name || default_name
      @errors      = ActiveModel::Errors.new(self)
    end

    def call
      ActiveRecord::Base.transaction do
        @meal_plan = find_or_build_plan
        clear_unfilled_slots!
        fill_slots!
        @meal_plan.recalculate_cost!
      end
      self
    rescue ActiveRecord::RecordInvalid => e
      @errors.add(:base, e.message)
      self
    end

    def success?
      @errors.empty?
    end

    private

    def find_or_build_plan
      MealPlan.find_or_create_by!(user: @user, week_start_date: @week_start) do |p|
        p.name   = @name
        p.status = "active"
      end
    end

    def clear_unfilled_slots!
      # Delete all entries that haven't been cooked yet so regeneration
      # produces a fresh set of recipes from the provider.
      @meal_plan.meal_plan_entries.where(cooked: false).delete_all
    end

    def fill_slots!
      provider.suggested_entries(plan: @meal_plan, preferences: @user.user_preference).each do |attrs|
        @meal_plan.meal_plan_entries.create!(
          day_of_week: attrs[:day_of_week],
          meal_slot:   attrs[:meal_slot],
          recipe_id:   attrs[:recipe_id],
          servings:    attrs[:servings]
        )
      end
    end

    def provider
      klass = PROVIDER_MAP.fetch(
        Rails.application.config.meal_ai_provider,
        MealPlans::Providers::DealAwareProvider
      )
      klass.new
    end

    def default_name
      "Week of #{@week_start.strftime("%b %-d, %Y")}"
    end
  end
end
