class UserRecipePreference < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :rating, numericality: { in: 1..5 }, allow_nil: true
  validates :user_id, uniqueness: { scope: :recipe_id }

  after_save    :update_recipe_aggregate
  after_destroy :update_recipe_aggregate

  scope :liked,   -> { where(liked: true) }
  scope :blocked, -> { where(liked: false) }
  scope :rated,   -> { where.not(rating: nil) }

  private

  def update_recipe_aggregate
    recipe.update_rating_aggregate!
  end
end
