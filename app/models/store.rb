class Store < ApplicationRecord
  has_many :deals, dependent: :destroy
  has_many :user_stores, dependent: :destroy
  has_many :users, through: :user_stores

  CHAINS = %w[publix kroger walmart target].freeze
  DEAL_TYPES = %w[bogo sale multi].freeze

  validates :chain, presence: true, inclusion: { in: CHAINS }
  validates :name,  presence: true

  scope :by_chain, ->(chain) { where(chain: chain) }
  scope :with_fresh_deals, -> { where(deals_fetched_at: 1.week.ago..) }

  def publix?
    chain == "publix"
  end

  def deals_stale?
    deals_fetched_at.nil? || deals_fetched_at < 1.day.ago
  end

  def active_deals
    deals.where("valid_until >= ?", Date.current)
  end
end
