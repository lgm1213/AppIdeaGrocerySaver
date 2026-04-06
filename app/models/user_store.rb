class UserStore < ApplicationRecord
  belongs_to :user
  belongs_to :store

  validates :user_id, uniqueness: { scope: :store_id }

  scope :primary, -> { where(primary: true) }

  def make_primary!
    UserStore.where(user_id: user_id).update_all(primary: false)
    update!(primary: true)
  end
end
