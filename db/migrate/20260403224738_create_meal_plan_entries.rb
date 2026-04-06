class CreateMealPlanEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_plan_entries, id: :uuid do |t|
      t.references :meal_plan, null: false, foreign_key: true, type: :uuid
      t.references :recipe,    foreign_key: true, type: :uuid  # nullable — empty slots allowed
      t.integer :day_of_week,  null: false  # 0 = Monday … 6 = Sunday
      t.string  :meal_slot,    null: false  # breakfast | lunch | dinner
      t.integer :servings,     default: 2,  null: false
      t.boolean :cooked,       default: false, null: false

      t.timestamps
    end

    add_index :meal_plan_entries, [ :meal_plan_id, :day_of_week, :meal_slot ], unique: true,
              name: "index_meal_plan_entries_on_plan_day_slot"
    add_index :meal_plan_entries, :cooked
  end
end
