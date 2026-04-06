class MatchDealsToIngredientsJob < ApplicationJob
  queue_as :default

  def perform
    matched = Deals::IngredientMatcher.new.match
    Rails.logger.info("[MatchDealsToIngredientsJob] Matched #{matched} deals to ingredients")
  end
end
