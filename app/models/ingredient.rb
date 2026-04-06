class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  CATEGORIES = %w[produce dairy meat seafood pantry frozen bakery beverages snacks].freeze

  validates :name,     presence: true, uniqueness: { case_sensitive: false }
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  normalizes :name, with: ->(n) { n.strip.titleize }

  scope :by_category, ->(cat) { where(category: cat) }
  scope :ordered,     -> { order(:category, :name) }
  scope :by_barcode,  ->(code) { find_by(barcode: code) }
end
