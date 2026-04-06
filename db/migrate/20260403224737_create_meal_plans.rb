class CreateMealPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_plans, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string  :name,                null: false
      t.date    :week_start_date,     null: false
      t.string  :status,              default: "active", null: false
      # status: active | archived
      t.decimal :total_estimated_cost, precision: 8, scale: 2

      t.timestamps
    end

    add_index :meal_plans, [ :user_id, :week_start_date ], unique: true
    add_index :meal_plans, :status
  end
end
