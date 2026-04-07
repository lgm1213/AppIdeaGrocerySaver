class Deal < ApplicationRecord
  belongs_to :store
  belongs_to :ingredient, optional: true

  DEAL_TYPES = %w[bogo sale multi].freeze

  validates :name,      presence: true
  validates :deal_type, presence: true, inclusion: { in: DEAL_TYPES }

  scope :active,          -> { where("valid_until IS NULL OR valid_until >= ?", Date.current) }
  scope :bogo,            -> { where(deal_type: "bogo") }
  scope :by_category,     ->(cat) { where(category: cat) }
  scope :matched,         -> { where.not(ingredient_id: nil) }
  scope :unmatched,       -> { where(ingredient_id: nil) }
  scope :for_recipes,     ->(ingredient_ids) { matched.where(ingredient_id: ingredient_ids) }

  # Includes deals from the stores' parent (chain-wide) stores as a fallback.
  # Individual store records may not have their own scraped deals yet — they
  # inherit from the chain-wide parent until a per-store scrape URL is configured.
  scope :for_user_stores, ->(stores) {
    return none if stores.blank?

    store_ids = stores.flat_map { |s| [ s.id, s.parent_store_id ] }.compact.uniq
    where(store_id: store_ids)
  }

  # Returns { recipe_id => total_savings } for recipes that use on-sale ingredients.
  # Includes parent store deals so individual-store users see chain-wide deals as fallback.
  def self.savings_by_recipe(stores:, recipe_ids:)
    return {} if stores.blank? || recipe_ids.blank?

    store_ids = stores.flat_map { |s| [ s.id, s.parent_store_id ] }.compact.uniq

    active
      .matched
      .where(store_id: store_ids)
      .joins("INNER JOIN recipe_ingredients ri ON ri.ingredient_id = deals.ingredient_id")
      .where("ri.recipe_id IN (?)", recipe_ids)
      .group("ri.recipe_id")
      .sum("COALESCE(deals.savings_amount, 5.0)")
  end

  # Human-friendly savings description
  def savings_label
    case deal_type
    when "bogo"  then "Buy 1 Get 1 Free"
    when "multi" then "#{multi_quantity} for $#{'%.2f' % sale_price}"
    when "sale"  then unit ? "$#{'%.2f' % sale_price}/#{unit}" : "$#{'%.2f' % sale_price}"
    end
  end

  def savings_display
    return "Save up to $#{'%.2f' % savings_amount}" if savings_amount&.positive?
    savings_label
  end

  def active?
    valid_until.nil? || valid_until >= Date.current
  end
end
