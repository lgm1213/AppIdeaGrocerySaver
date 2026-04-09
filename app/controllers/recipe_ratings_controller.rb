class RecipeRatingsController < ApplicationController
  before_action :require_authentication
  before_action :set_recipe

  # POST /recipes/:recipe_id/rating
  # Handles both star rating and like/block toggle from a single endpoint.
  # Params: rating (1-5), liked (true/false/nil)
  def upsert
    @preference = Current.user.user_recipe_preferences.find_or_initialize_by(recipe_id: @recipe.id)

    @preference.rating = params[:rating].presence&.to_i if params.key?(:rating)
    @preference.liked  = parse_liked(params[:liked])    if params.key?(:liked)
    @preference.save!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "recipe_rating_#{@recipe.id}",
            partial: "recipes/rating_widget",
            locals:  { recipe: @recipe, preference: @preference }
          ),
          turbo_stream.remove("rating_prompt_#{params[:entry_id]}") # dismiss post-cook prompt if present
        ]
      end
      format.html { redirect_back fallback_location: recipe_path(@recipe) }
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  # "true" → true, "false" → false, "" / nil → nil (clear preference)
  def parse_liked(value)
    return nil if value.blank? || value == "nil"

    ActiveModel::Type::Boolean.new.cast(value)
  end
end
