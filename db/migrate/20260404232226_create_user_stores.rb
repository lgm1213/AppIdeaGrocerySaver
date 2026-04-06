class CreateUserStores < ActiveRecord::Migration[8.1]
  def change
    create_table :user_stores, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :user,  type: :uuid, null: false, foreign_key: true
      t.references :store, type: :uuid, null: false, foreign_key: true
      t.boolean    :primary, default: false, null: false

      t.timestamps
    end

    add_index :user_stores, [ :user_id, :store_id ], unique: true
  end
end
