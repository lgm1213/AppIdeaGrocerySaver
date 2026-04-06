class CreateUserPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :user_preferences, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }

      # Step 1 — Dietary & lifestyle
      t.string  :dietary_restrictions, array: true, default: []
      t.string  :preferred_cuisines,   array: true, default: []
      t.integer :household_size,       default: 2,  null: false
      t.string  :cooking_skill,        default: "beginner", null: false
      # cooking_skill: beginner | intermediate | advanced

      # Step 2 — Budget & location
      t.decimal :weekly_budget,        precision: 8, scale: 2
      t.string  :budget_currency,      default: "USD"
      t.string  :zip_code
      t.string  :city
      t.string  :state
      t.string  :preferred_store

      # Meal planning preferences
      t.integer :meals_per_week,       default: 7,  null: false
      t.string  :meal_complexity,      default: "moderate"
      # meal_complexity: quick | moderate | elaborate
      t.boolean :include_breakfast,    default: true, null: false
      t.boolean :include_lunch,        default: true, null: false
      t.boolean :include_dinner,       default: true, null: false

      t.timestamps
    end

    add_index :user_preferences, :zip_code
  end
end
