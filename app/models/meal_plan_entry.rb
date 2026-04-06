class MealPlanEntry < ApplicationRecord
  belongs_to :meal_plan
  belongs_to :recipe, optional: true

  MEAL_SLOTS  = MealPlan::MEAL_SLOTS.freeze
  DAYS        = MealPlan::DAYS.freeze
  SLOT_ORDER  = { "breakfast" => 0, "lunch" => 1, "dinner" => 2 }.freeze

  validates :day_of_week, presence: true,
                          numericality: { only_integer: true, in: 0..6 }
  validates :meal_slot,   presence: true, inclusion: { in: MEAL_SLOTS }
  validates :servings,    numericality: { only_integer: true, greater_than: 0 }
  validates :meal_plan_id, uniqueness: { scope: %i[day_of_week meal_slot],
                                         message: "already has a recipe for that slot" }

  scope :filled,     -> { where.not(recipe_id: nil) }
  scope :empty_slot, -> { where(recipe_id: nil) }
  scope :cooked,     -> { where(cooked: true) }
  scope :for_day,    ->(day) { where(day_of_week: day) }
  scope :for_slot,   ->(slot) { where(meal_slot: slot) }
  SLOT_ORDER_SQL = Arel.sql("CASE meal_slot WHEN 'breakfast' THEN 0 WHEN 'lunch' THEN 1 WHEN 'dinner' THEN 2 END").freeze

  scope :ordered,    -> { order(:day_of_week, SLOT_ORDER_SQL) }

  # ── Helpers ──────────────────────────────────────────────────────────────

  def day_name
    DAYS[day_of_week]
  end

  def empty?
    recipe_id.nil?
  end

  def filled?
    recipe_id.present?
  end

  def slot_label
    meal_slot.capitalize
  end

  def mark_cooked!
    update!(cooked: true)
  end

  def unmark_cooked!
    update!(cooked: false)
  end

  def cost_estimate
    return nil unless recipe && recipe.estimated_cost && recipe.servings&.positive?

    (recipe.estimated_cost * servings / recipe.servings).round(2)
  end

  def cost_display
    return "N/A" unless cost_estimate

    format("$%.2f", cost_estimate)
  end
end
