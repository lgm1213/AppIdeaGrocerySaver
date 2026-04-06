class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  validates :recipe_id,     presence: true
  validates :ingredient_id, presence: true
  validates :quantity,      numericality: { greater_than: 0 }, allow_nil: true

  def display_unit
    unit.presence || ingredient.default_unit
  end

  def quantity_label
    return ingredient.name unless quantity

    "#{quantity.to_s.sub(/\.?0+$/, '')} #{display_unit} #{ingredient.name}".strip
  end
end
