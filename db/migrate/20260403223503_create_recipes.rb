class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes, id: :uuid do |t|
      t.string  :name,               null: false
      t.text    :description
      t.text    :instructions
      t.integer :prep_time_minutes,  default: 10
      t.integer :cook_time_minutes,  default: 20
      t.integer :servings,           default: 2,     null: false
      t.string  :difficulty,         default: "easy" # easy | medium | hard
      t.string  :meal_type,          null: false     # breakfast | lunch | dinner | snack
      t.string  :cuisine
      t.decimal :estimated_cost,     precision: 8, scale: 2
      t.integer :calories_per_serving

      # Denormalized dietary flags for fast filtering
      t.boolean :is_vegetarian,  default: false, null: false
      t.boolean :is_vegan,       default: false, null: false
      t.boolean :is_gluten_free, default: false, null: false
      t.boolean :is_dairy_free,  default: false, null: false
      t.boolean :is_keto,        default: false, null: false

      # Searchable tags (gin-indexed pg array)
      t.string  :tags, array: true, default: []

      # Source tracking for AI integration scaffold
      t.string  :source,       default: "seed"  # seed | ai_generated | user_created
      t.string  :external_id

      t.timestamps
    end

    add_index :recipes, :meal_type
    add_index :recipes, :difficulty
    add_index :recipes, :tags, using: :gin
    add_index :recipes, :is_vegetarian
    add_index :recipes, :is_vegan
    add_index :recipes, :is_gluten_free
    add_index :recipes, :name
  end
end
