class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients, id: :uuid do |t|
      t.string  :name,          null: false
      t.string  :category,      null: false   # produce | dairy | meat | pantry | frozen | bakery | seafood
      t.string  :default_unit                 # cup | oz | lb | piece | tsp | tbsp | bunch
      t.decimal :average_price, precision: 8, scale: 2
      t.string  :barcode                      # UPC for scanner feature

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
    add_index :ingredients, :barcode, where: "barcode IS NOT NULL"
    add_index :ingredients, :category
  end
end
