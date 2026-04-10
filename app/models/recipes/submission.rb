module Recipes
  class Submission
    include ActiveModel::Model

    attr_accessor :name, :meal_type, :difficulty, :servings, :description,
                  :prep_time_minutes, :cook_time_minutes, :cuisine,
                  :ingredient_rows

    validates :name,      presence: true
    validates :meal_type, presence: true, inclusion: { in: Recipe::MEAL_TYPES }
    validates :servings,  numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
    validate  :at_least_one_ingredient

    # Returns the persisted Recipe on success, false on failure.
    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        recipe = Recipe.create!(
          name:              name,
          meal_type:         meal_type,
          difficulty:        difficulty.presence || "easy",
          servings:          servings.present? ? servings.to_i : 2,
          description:       description,
          prep_time_minutes: prep_time_minutes.presence&.to_i,
          cook_time_minutes: cook_time_minutes.presence&.to_i,
          cuisine:           cuisine.presence,
          source:            "user_created"
        )

        valid_rows.each do |row|
          RecipeIngredient.create!(
            recipe:     recipe,
            ingredient: Ingredient.find(fetch_str(row, :ingredient_id)),
            quantity:   fetch_str(row, :quantity)&.to_f,
            unit:       fetch_str(row, :unit)
          )
        end

        recipe
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    private

    def valid_rows
      rows = ingredient_rows.respond_to?(:values) ? ingredient_rows.values : Array(ingredient_rows)
      rows.reject { |r| fetch_str(r, :ingredient_id).blank? }
    end

    def at_least_one_ingredient
      errors.add(:base, "At least one ingredient is required") if valid_rows.empty?
    end

    # Reads a key from a row that may have string or symbol keys (params vs plain Hash).
    def fetch_str(row, key)
      row[key].presence || row[key.to_s].presence
    end
  end
end
