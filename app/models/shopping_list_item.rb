class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :ingredient, optional: true

  CATEGORIES = Ingredient::CATEGORIES

  validates :name,     presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :checked,   -> { where(checked: true) }
  scope :unchecked, -> { where(checked: false) }
  scope :by_category, -> { order(:category, :position, :name) }

  CATEGORY_ICONS = {
    "produce"   => "🥦",
    "dairy"     => "🥛",
    "meat"      => "🥩",
    "seafood"   => "🐟",
    "pantry"    => "🫙",
    "frozen"    => "🧊",
    "bakery"    => "🍞",
    "beverages" => "🧃",
    "snacks"    => "🍿"
  }.freeze

  def check!
    update!(checked: true)
  end

  def uncheck!
    update!(checked: false)
  end

  def toggle!
    update!(checked: !checked)
  end

  def quantity_label
    return name unless quantity

    qty = quantity.to_s.sub(/\.?0+$/, "")
    [ qty, unit, name ].compact.join(" ")
  end

  def category_icon
    CATEGORY_ICONS.fetch(category, "🛒")
  end
end
