class SystemSetting < ApplicationRecord
  SMTP_KEYS = %w[
    smtp_address
    smtp_port
    smtp_domain
    smtp_username
    smtp_password
    smtp_authentication
    smtp_enable_starttls_auto
    smtp_from_address
  ].freeze

  validates :key, presence: true, uniqueness: true

  # Read a setting value by key
  def self.[](key)
    find_by(key: key)&.value
  end

  # Write a setting value by key (upsert)
  def self.[]=(key, value)
    setting = find_or_initialize_by(key: key)
    setting.update!(value: value.to_s)
  end

  def self.smtp_configured?
    self[:smtp_address].present?
  end

  # Returns a hash suitable for ActionMailer::Base.smtp_settings
  def self.current_smtp_settings
    {
      address:              self[:smtp_address],
      port:                 self[:smtp_port]&.to_i || 587,
      domain:               self[:smtp_domain],
      user_name:            self[:smtp_username],
      password:             self[:smtp_password],
      authentication:       self[:smtp_authentication].presence || "plain",
      enable_starttls_auto: self[:smtp_enable_starttls_auto] != "false"
    }
  end

  # Apply current DB settings to ActionMailer in-memory (no restart needed)
  def self.apply_smtp!
    return unless smtp_configured?

    ActionMailer::Base.delivery_method    = :smtp
    ActionMailer::Base.smtp_settings      = current_smtp_settings
    ActionMailer::Base.default_options    = { from: self[:smtp_from_address].presence || "noreply@example.com" }
  end
end
