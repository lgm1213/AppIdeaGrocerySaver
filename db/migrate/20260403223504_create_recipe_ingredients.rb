class CreateRecipeIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_ingredients, id: :uuid do |t|
      t.references :recipe,     null: false, foreign_key: true, type: :uuid
      t.references :ingredient, null: false, foreign_key: true, type: :uuid
      t.decimal :quantity,  precision: 8, scale: 3
      t.string  :unit       # overrides ingredient default_unit
      t.string  :notes      # "finely diced", "optional", etc.

      t.timestamps
    end

    add_index :recipe_ingredients, [ :recipe_id, :ingredient_id ], unique: true
  end
end
