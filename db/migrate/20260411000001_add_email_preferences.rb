class AddEmailPreferences < ActiveRecord::Migration[8.1]
  def up
    # Permanent token used in unsubscribe URLs — no login required.
    add_column :users, :unsubscribe_token, :string
    add_index  :users, :unsubscribe_token, unique: true

    # Per-category email opt-out stored alongside other preferences.
    add_column :user_preferences, :email_deal_alerts, :boolean, default: true, null: false

    # Backfill a unique token for every existing user.
    User.find_each do |user|
      user.update_column(:unsubscribe_token, SecureRandom.urlsafe_base64(24))
    end

    # Make the column required once backfilled.
    change_column_null :users, :unsubscribe_token, false
  end

  def down
    remove_index  :users, :unsubscribe_token
    remove_column :users, :unsubscribe_token
    remove_column :user_preferences, :email_deal_alerts
  end
end
