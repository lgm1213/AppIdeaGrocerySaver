class AddRatingColumnsToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :average_rating, :decimal, precision: 3, scale: 2, default: 0.0, null: false
    add_column :recipes, :ratings_count,  :integer, default: 0, null: false

    add_index :recipes, :average_rating
    add_index :recipes, :ratings_count
  end
end
