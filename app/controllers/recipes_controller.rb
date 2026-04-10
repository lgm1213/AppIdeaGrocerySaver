class RecipesController < ApplicationController
  include Pagy::Backend

  before_action :require_onboarding_complete

  def index
    @recipes = base_recipes
    @recipes = apply_filters(@recipes)
    @pagy, @recipes = pagy(@recipes.order(order_clause), items: 24)

    @cuisines       = Recipe.distinct.pluck(:cuisine).compact.sort
    @on_sale_active = params[:on_sale] == "1"

    # Pre-load current user's preferences for displayed recipes
    @preference_map = preference_map_for(@recipes)
  end

  def show
    @recipe           = Recipe.includes(:ingredients, :recipe_ingredients).find(params[:id])
    @preference       = Current.user.user_recipe_preferences.find_by(recipe_id: @recipe.id)
    @on_sale_deals    = on_sale_deals_for(@recipe)
    @user_rated       = @preference&.rating.present?
  end

  def new
    @submission  = Recipes::Submission.new
    @ingredients = Ingredient.order(:name)
  end

  def create
    @submission  = Recipes::Submission.new(submission_params)
    @ingredients = Ingredient.order(:name)
    recipe       = @submission.save

    if recipe
      redirect_to recipe_path(recipe), notice: "Recipe added successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def base_recipes
    Recipe.includes(:ingredients)
  end

  def apply_filters(scope)
    scope = scope.for_meal(params[:meal_type])         if params[:meal_type].present?
    scope = scope.by_cuisine(params[:cuisine])         if params[:cuisine].present?

    Array(params[:dietary]).reject(&:blank?).each do |r|
      col = Recipe::DIETARY_COLUMN_MAP[r]
      scope = scope.where(col => true) if col
    end

    if params[:on_sale] == "1"
      store_ids = on_sale_store_ids
      scope = scope.with_on_sale_ingredients(store_ids) if store_ids.any?
    end

    scope
  end

  def order_clause
    case params[:sort]
    when "top_rated"  then "average_rating DESC, ratings_count DESC, name ASC"
    when "quick"      then "prep_time_minutes + cook_time_minutes ASC, name ASC"
    when "budget"     then "estimated_cost ASC NULLS LAST, name ASC"
    else                   "meal_type ASC, name ASC"
    end
  end

  def on_sale_store_ids
    stores = Current.user.stores.any? ? Current.user.stores : Store.where(chain: "publix")
    stores.flat_map { |s| [ s.id, s.parent_store_id ].compact }.uniq
  end

  def on_sale_deals_for(recipe)
    store_ids = on_sale_store_ids
    return [] if store_ids.empty?

    Deal.active
        .where(store_id: store_ids)
        .where(ingredient_id: recipe.ingredients.pluck(:id))
        .includes(:ingredient)
  end

  def submission_params
    params.require(:recipes_submission).permit(
      :name, :meal_type, :difficulty, :servings, :description,
      :prep_time_minutes, :cook_time_minutes, :cuisine,
      ingredient_rows: [ :ingredient_id, :quantity, :unit ]
    )
  end

  def preference_map_for(recipes)
    recipe_ids = recipes.map(&:id)
    Current.user.user_recipe_preferences
           .where(recipe_id: recipe_ids)
           .index_by(&:recipe_id)
  end
end
