class UserPreference < ApplicationRecord
  belongs_to :user

  DIETARY_OPTIONS = %w[
    vegetarian vegan gluten_free dairy_free nut_free
    keto paleo halal kosher low_sodium
  ].freeze

  CUISINE_OPTIONS = %w[
    american italian mexican asian mediterranean
    indian chinese japanese thai french greek middle_eastern
  ].freeze

  COOKING_SKILLS  = %w[beginner intermediate advanced].freeze
  COMPLEXITIES    = %w[quick moderate elaborate].freeze

  validates :household_size, numericality: { in: 1..20 }
  validates :cooking_skill, inclusion: { in: COOKING_SKILLS }
  validates :meal_complexity, inclusion: { in: COMPLEXITIES }
  validates :meals_per_week, numericality: { in: 1..21 }
  validates :weekly_budget,
            numericality: { greater_than: 0 },
            allow_nil: true
  validates :zip_code,
            zipcode: { country_code: :us },
            allow_blank: true

  # ── Scopes ──────────────────────────────────────────────────────────────

  scope :by_zip, ->(zip) { where(zip_code: zip) }

  # ── Helpers ─────────────────────────────────────────────────────────────

  def dietary_label
    return "No restrictions" if dietary_restrictions.blank?

    dietary_restrictions.map { |d| d.humanize.titleize }.join(", ")
  end

  def cuisine_label
    return "All cuisines" if preferred_cuisines.blank?

    preferred_cuisines.map { |c| c.humanize.titleize }.join(", ")
  end

  def budget_display
    return "Not set" unless weekly_budget

    "$#{weekly_budget.to_i}/week"
  end

  def skill_label
    cooking_skill.humanize.titleize
  end
end
