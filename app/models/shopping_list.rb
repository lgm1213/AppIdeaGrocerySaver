class ShoppingList < ApplicationRecord
  belongs_to :user
  belongs_to :meal_plan, optional: true
  has_many   :shopping_list_items, -> { order(:category, :position, :name) }, dependent: :destroy

  STATUSES = %w[active completed].freeze

  validates :name,   presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :active,    -> { where(status: "active") }
  scope :completed, -> { where(status: "completed") }
  scope :recent,    -> { order(created_at: :desc) }

  # ── Class factory ────────────────────────────────────────────────────────

  # Builds a shopping list from a meal plan by aggregating recipe ingredients.
  # Combines duplicate ingredients, sums quantities.
  def self.generate_from_plan!(meal_plan, user)
    list = create!(
      user:      user,
      meal_plan: meal_plan,
      name:      "Shopping for #{meal_plan.name}",
      status:    "active"
    )

    aggregated = aggregate_ingredients(meal_plan)

    aggregated.each_with_index do |(ingredient_id, data), idx|
      list.shopping_list_items.create!(
        ingredient_id: ingredient_id,
        name:          data[:name],
        quantity:      data[:quantity]&.positive? ? data[:quantity].round(2) : nil,
        unit:          data[:unit],
        category:      data[:category],
        position:      idx
      )
    end

    list
  end

  # ── Instance helpers ─────────────────────────────────────────────────────

  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end

  def mark_complete!
    update!(status: "completed")
  end

  def total_items
    shopping_list_items.count
  end

  def checked_count
    shopping_list_items.where(checked: true).count
  end

  def completion_percentage
    return 0 if total_items.zero?
    (checked_count.to_f / total_items * 100).round
  end

  def items_by_category
    shopping_list_items.group_by(&:category)
  end

  private

  def self.aggregate_ingredients(meal_plan)
    entries = meal_plan.meal_plan_entries
      .includes(recipe: { recipe_ingredients: :ingredient })
      .where.not(recipe_id: nil)

    totals = {}

    entries.each do |entry|
      scale = entry.recipe.servings.positive? ? entry.servings.to_f / entry.recipe.servings : 1.0

      entry.recipe.recipe_ingredients.each do |ri|
        ing = ri.ingredient
        key = ing.id

        if totals[key]
          totals[key][:quantity] += (ri.quantity || 0) * scale if ri.quantity
        else
          totals[key] = {
            name:     ing.name,
            quantity: ri.quantity ? (ri.quantity * scale) : nil,
            unit:     ri.unit.presence || ing.default_unit,
            category: ing.category
          }
        end
      end
    end

    # Sort by category then name
    totals.sort_by { |_, v| [ v[:category], v[:name] ] }.to_h
  end
end
