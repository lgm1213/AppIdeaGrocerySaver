class CreateDeals < ActiveRecord::Migration[8.1]
  def change
    create_table :deals, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :store,      type: :uuid, null: false, foreign_key: true
      t.references :ingredient, type: :uuid, foreign_key: true   # nullable — matched after scrape

      t.string  :publix_item_code                  # data-item-code from Publix DOM
      t.string  :name,         null: false          # product name as scraped
      t.string  :category                           # Meat, Produce, Dairy, etc.
      t.string  :deal_type,    null: false          # bogo | sale | multi
      t.string  :badge_text                         # raw badge: "buy 1 get 1 free", "$3.79 lb"
      t.decimal :sale_price,   precision: 8, scale: 2
      t.decimal :savings_amount, precision: 8, scale: 2
      t.string  :unit                               # lb, oz, each, etc.
      t.integer :multi_quantity                     # for "2 for $X" deals
      t.date    :valid_from
      t.date    :valid_until
      t.jsonb   :raw_data, default: {}

      t.timestamps
    end

    add_index :deals, :category
    add_index :deals, :deal_type
    add_index :deals, :valid_until
    add_index :deals, [ :store_id, :publix_item_code ], unique: true,
              where: "publix_item_code IS NOT NULL", name: "index_deals_on_store_and_item_code"
  end
end
