class CreateShoppingLists < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_lists, id: :uuid do |t|
      t.references :user,      null: false, foreign_key: true, type: :uuid
      t.references :meal_plan, foreign_key: true, type: :uuid  # nullable — manual lists allowed

      t.string  :name,   null: false
      t.string  :status, null: false, default: "active"  # active | completed
      t.text    :notes
      t.date    :shop_date

      t.timestamps
    end

    add_index :shopping_lists, :status
    add_index :shopping_lists, [ :user_id, :created_at ]
  end
end
