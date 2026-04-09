class SavingsController < ApplicationController
  before_action :require_authentication
  before_action :require_onboarding_complete

  def index
    @summary = Savings::SummaryService.new(Current.user)
    @weekly  = @summary.weekly_data(weeks: 8)

    budget = Current.user.user_preference&.weekly_budget.to_f
    max_cost = @weekly.map { |w| w[:estimated_cost] }.max.to_f
    @chart_max = [ max_cost, budget, 1.0 ].max
  end
end
