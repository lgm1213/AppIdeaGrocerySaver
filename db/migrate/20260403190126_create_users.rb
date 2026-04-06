class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false

      # OmniAuth (Google OAuth2)
      t.string :provider
      t.string :uid

      # Display
      t.string :display_name
      t.string :avatar_url

      # Onboarding state
      t.string  :onboarding_step,     default: "preferences", null: false
      t.boolean :onboarding_complete,  default: false,         null: false

      t.timestamps
    end

    add_index :users, :email_address, unique: true
    add_index :users, [ :provider, :uid ], unique: true, where: "provider IS NOT NULL"
  end
end
