class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string   :chain,           null: false   # "publix", "kroger", etc.
      t.string   :name,            null: false   # human-readable: "Publix"
      t.string   :address
      t.string   :city
      t.string   :state
      t.string   :zip_code
      t.string   :store_number                   # chain-specific store ID
      t.string   :scrape_url                     # URL to scrape weekly ad
      t.datetime :deals_fetched_at

      t.timestamps
    end

    add_index :stores, :chain
    add_index :stores, [ :chain, :store_number ], unique: true, where: "store_number IS NOT NULL"
  end
end
