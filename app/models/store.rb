class Store < ApplicationRecord
  belongs_to :parent_store, class_name: "Store", optional: true
  has_many   :child_stores, class_name: "Store", foreign_key: "parent_store_id", dependent: :nullify,
                            inverse_of: :parent_store

  has_many :deals, dependent: :destroy
  has_many :user_stores, dependent: :destroy
  has_many :users, through: :user_stores

  CHAINS = %w[publix kroger aldi walmart target].freeze

  validates :chain, presence: true, inclusion: { in: CHAINS }
  validates :name,  presence: true

  scope :by_chain,        ->(chain) { where(chain: chain) }
  scope :chain_wide,      -> { where(store_number: nil) }
  scope :scrapeable,      -> { where.not(scrape_url: nil) }
  scope :with_fresh_deals, -> { where(deals_fetched_at: 1.week.ago..) }

  # A store is scrapeable if it has its own URL to hit.
  def scrapeable?
    scrape_url.present?
  end

  def deals_stale?
    deals_fetched_at.nil? || deals_fetched_at < 1.day.ago
  end

  # The store to use as deal source: self if scrapeable, otherwise the parent chain-wide store.
  def canonical_store
    scrapeable? ? self : (parent_store || self)
  end

  def active_deals
    deals.where("valid_until >= ?", Date.current)
  end
end
