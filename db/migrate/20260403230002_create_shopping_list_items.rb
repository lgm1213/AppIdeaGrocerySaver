class CreateShoppingListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_items, id: :uuid do |t|
      t.references :shopping_list, null: false, foreign_key: true, type: :uuid
      t.references :ingredient,    foreign_key: true, type: :uuid  # nullable — custom items have no ingredient

      t.string  :name,      null: false          # display name (copied from ingredient or typed)
      t.decimal :quantity,  precision: 8, scale: 3
      t.string  :unit
      t.string  :category,  null: false, default: "pantry"
      t.boolean :checked,   null: false, default: false
      t.integer :position,  null: false, default: 0
      t.text    :notes

      t.timestamps
    end

    add_index :shopping_list_items, [ :shopping_list_id, :checked ]
    add_index :shopping_list_items, [ :shopping_list_id, :position ]
    add_index :shopping_list_items, :category
  end
end
