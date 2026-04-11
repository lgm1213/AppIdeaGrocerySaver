class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  CATEGORIES = %w[produce dairy meat seafood pantry frozen bakery beverages snacks].freeze

  # Maps our internal category names to strings we expect to appear in
  # retailer-supplied deal category fields (e.g. Kroger API categories,
  # Publix/Aldi scraped section headings). Used by IngredientMatcher to
  # reject obvious category mismatches (e.g. "Chicken" → "Chicken Broth").
  CATEGORY_DEAL_HINTS = {
    "produce"   => %w[produce fruit vegetable fresh salad greens organic],
    "dairy"     => %w[dairy milk cheese yogurt butter cream egg],
    "meat"      => %w[meat poultry chicken beef pork lamb turkey bacon sausage],
    "seafood"   => %w[seafood fish shrimp salmon tuna crab lobster],
    "pantry"    => %w[pantry canned sauce pasta rice grain condiment spice oil vinegar],
    "frozen"    => %w[frozen],
    "bakery"    => %w[bakery bread bake muffin cake cookie bagel tortilla],
    "beverages" => %w[beverage drink juice water soda coffee tea],
    "snacks"    => %w[snack chip cracker candy nut pretzel]
  }.freeze

  validates :name,     presence: true, uniqueness: { case_sensitive: false }
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  normalizes :name, with: ->(n) { n.strip.titleize }

  scope :by_category, ->(cat) { where(category: cat) }
  scope :ordered,     -> { order(:category, :name) }
  scope :by_barcode,  ->(code) { find_by(barcode: code) }

  # Returns true when the given deal_category string is plausible for this
  # ingredient. Always returns true when deal_category is blank — scrapers
  # don't always capture a category, and we don't want to block those deals.
  def category_compatible?(deal_category)
    return true if deal_category.blank?

    hints = CATEGORY_DEAL_HINTS[category] || []
    return true if hints.empty?

    downcased = deal_category.downcase
    hints.any? { |hint| downcased.include?(hint) }
  end
end
