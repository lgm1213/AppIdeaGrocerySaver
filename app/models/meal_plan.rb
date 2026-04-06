class MealPlan < ApplicationRecord
  belongs_to :user
  has_many :meal_plan_entries, dependent: :destroy
  has_many :recipes,           through: :meal_plan_entries
  has_many :shopping_lists,    dependent: :nullify

  STATUSES = %w[active archived].freeze
  MEAL_SLOTS = %w[breakfast lunch dinner].freeze
  DAYS = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze

  validates :name,            presence: true
  validates :week_start_date, presence: true
  validates :status,          inclusion: { in: STATUSES }
  validates :user_id,         uniqueness: { scope: :week_start_date,
                                message: "already has a plan for that week" }

  scope :active,   -> { where(status: "active") }
  scope :archived, -> { where(status: "archived") }
  scope :recent,   -> { order(week_start_date: :desc) }
  scope :for_week, ->(date) { where(week_start_date: date.beginning_of_week(:monday)) }

  # ── Class helpers ────────────────────────────────────────────────────────

  def self.current_week_start
    Date.current.beginning_of_week(:monday)
  end

  # ── Instance helpers ─────────────────────────────────────────────────────

  def week_end_date
    week_start_date + 6.days
  end

  def week_label
    "#{week_start_date.strftime("%b %-d")} – #{week_end_date.strftime("%b %-d, %Y")}"
  end

  def current_week?
    week_start_date == self.class.current_week_start
  end

  def archived?
    status == "archived"
  end

  def archive!
    update!(status: "archived")
  end

  # Returns a 2D hash: { 0 => { "breakfast" => entry|nil, ... }, 1 => {...}, ... }
  def grid
    @grid ||= begin
      entries_map = meal_plan_entries
        .includes(:recipe)
        .each_with_object({}) do |e, h|
          h[[ e.day_of_week, e.meal_slot ]] = e
        end

      (0..6).each_with_object({}) do |day, h|
        h[day] = MEAL_SLOTS.each_with_object({}) do |slot, sh|
          sh[slot] = entries_map[[ day, slot ]]
        end
      end
    end
  end

  def total_recipes
    meal_plan_entries.where.not(recipe_id: nil).count
  end

  def cooked_count
    meal_plan_entries.where(cooked: true).count
  end

  def completion_percentage
    total = total_recipes
    return 0 if total.zero?

    (cooked_count.to_f / total * 100).round
  end

  def estimated_cost_display
    return "N/A" unless total_estimated_cost

    format("$%.2f", total_estimated_cost)
  end

  def recalculate_cost!
    cost = meal_plan_entries
      .joins(:recipe)
      .sum("recipes.estimated_cost * meal_plan_entries.servings / NULLIF(recipes.servings, 0)")
    update!(total_estimated_cost: cost.positive? ? cost : nil)
  end
end
