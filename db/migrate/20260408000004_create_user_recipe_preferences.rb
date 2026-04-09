class CreateUserRecipePreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :user_recipe_preferences, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user,   null: false, foreign_key: true, type: :uuid
      t.references :recipe, null: false, foreign_key: true, type: :uuid

      # nil = no opinion, true = liked (suggest more), false = blocked (never suggest)
      t.boolean  :liked
      # 1–5 star rating, set after cooking — nil until the user rates
      t.integer  :rating
      # incremented each time toggle_cooked marks this recipe as cooked
      t.integer  :cooked_count,   null: false, default: 0
      t.datetime :last_cooked_at

      t.timestamps
    end

    add_index :user_recipe_preferences, [ :user_id, :recipe_id ], unique: true
    add_index :user_recipe_preferences, :rating
    add_index :user_recipe_preferences, :liked
  end
end
