class Recipe < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :meal_plan_entries, dependent: :nullify

  MEAL_TYPES  = %w[breakfast lunch dinner snack].freeze
  DIFFICULTIES = %w[easy medium hard].freeze
  SOURCES      = %w[seed ai_generated user_created].freeze

  validates :name,      presence: true
  validates :meal_type, presence: true, inclusion: { in: MEAL_TYPES }
  validates :difficulty, inclusion: { in: DIFFICULTIES }
  validates :servings,   numericality: { greater_than: 0 }

  # ── Scopes — query logic stays in the model ─────────────────────────────

  scope :breakfast,    -> { where(meal_type: "breakfast") }
  scope :lunch,        -> { where(meal_type: "lunch") }
  scope :dinner,       -> { where(meal_type: "dinner") }
  scope :for_meal,     ->(type) { where(meal_type: type) }

  scope :easy,         -> { where(difficulty: "easy") }
  scope :quick,        -> { where("prep_time_minutes + cook_time_minutes <= 30") }

  scope :vegetarian,   -> { where(is_vegetarian: true) }
  scope :vegan,        -> { where(is_vegan: true) }
  scope :gluten_free,  -> { where(is_gluten_free: true) }
  scope :dairy_free,   -> { where(is_dairy_free: true) }
  scope :keto,         -> { where(is_keto: true) }

  scope :by_cuisine,   ->(c) { where(cuisine: c) }
  scope :with_tag,     ->(t) { where("? = ANY(tags)", t) }
  scope :ordered,      -> { order(:meal_type, :name) }

  DIETARY_COLUMN_MAP = {
    "vegetarian"  => :is_vegetarian,
    "vegan"       => :is_vegan,
    "gluten_free" => :is_gluten_free,
    "dairy_free"  => :is_dairy_free,
    "keto"        => :is_keto
  }.freeze

  scope :matching_preferences, ->(pref) {
    return all unless pref

    scope = all
    Array(pref.dietary_restrictions).reject(&:blank?).each do |r|
      col = DIETARY_COLUMN_MAP[r]
      scope = scope.where(col => true) if col
    end
    scope
  }

  # ── Helpers ──────────────────────────────────────────────────────────────

  def total_time_minutes
    (prep_time_minutes || 0) + (cook_time_minutes || 0)
  end

  def total_time_label
    mins = total_time_minutes
    return "#{mins} min" if mins < 60

    hours = mins / 60
    remainder = mins % 60
    remainder.zero? ? "#{hours}h" : "#{hours}h #{remainder}m"
  end

  def dietary_badges
    badges = []
    badges << "Vegetarian" if is_vegetarian
    badges << "Vegan"      if is_vegan
    badges << "GF"         if is_gluten_free
    badges << "DF"         if is_dairy_free
    badges << "Keto"       if is_keto
    badges
  end

  def cost_display
    return "N/A" unless estimated_cost

    format("$%.2f", estimated_cost)
  end
end
