class User < ApplicationRecord
  has_secure_password validations: false
  has_many :sessions,                dependent: :destroy
  has_many :meal_plans,              dependent: :destroy
  has_many :shopping_lists,          dependent: :destroy
  has_one  :user_preference,         dependent: :destroy
  has_many :user_stores,             dependent: :destroy
  has_many :stores,                  through: :user_stores
  has_many :user_recipe_preferences, dependent: :destroy
  has_many :preferred_recipes,       through: :user_recipe_preferences, source: :recipe

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  before_create :generate_unsubscribe_token

  validates :email_address, presence: true,
                             format: { with: URI::MailTo::EMAIL_REGEXP },
                             uniqueness: { case_sensitive: false }

  # Password required only for email/password sign-up (not OAuth)
  validates :password, length: { minimum: 12 }, allow_nil: true
  validates :password, presence: true, on: :create, unless: :oauth_user?

  ONBOARDING_STEPS = %w[preferences budget_location recap complete].freeze

  scope :with_provider, ->(provider, uid) { find_by(provider: provider, uid: uid) }

  # ── OmniAuth ────────────────────────────────────────────────────────────

  def self.find_or_create_from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    user ||= find_by(email_address: auth.info.email.strip.downcase)

    if user
      user.update!(
        provider:     auth.provider,
        uid:          auth.uid,
        display_name: user.display_name.presence || auth.info.name,
        avatar_url:   user.avatar_url.presence || auth.info.image
      )
    else
      user = create!(
        email_address: auth.info.email.strip.downcase,
        provider:      auth.provider,
        uid:           auth.uid,
        display_name:  auth.info.name,
        avatar_url:    auth.info.image,
        password:      nil
      )
    end

    user
  end

  # ── Onboarding state machine ─────────────────────────────────────────────

  def next_onboarding_step
    current_index = ONBOARDING_STEPS.index(onboarding_step) || 0
    ONBOARDING_STEPS[current_index + 1]
  end

  def advance_onboarding!
    next_step = next_onboarding_step
    if next_step == "complete"
      update!(onboarding_step: "complete", onboarding_complete: true)
    else
      update!(onboarding_step: next_step)
    end
  end

  # ── Display helpers ──────────────────────────────────────────────────────

  def name
    display_name.presence || email_address.split("@").first.capitalize
  end

  def initials
    parts = name.split
    parts.length >= 2 ? "#{parts[0][0]}#{parts[-1][0]}".upcase : name[0..1].upcase
  end

  private

  def oauth_user?
    provider.present?
  end

  def generate_unsubscribe_token
    self.unsubscribe_token ||= SecureRandom.urlsafe_base64(24)
  end
end
