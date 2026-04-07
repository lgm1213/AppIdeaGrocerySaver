class AddDealsLastSeenAtToUserPreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :user_preferences, :deals_last_seen_at, :datetime
  end
end
