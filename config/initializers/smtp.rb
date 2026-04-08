# Apply SMTP settings from the system_settings DB table (if configured).
# This runs at boot. Admin can update settings via /admin/email_settings —
# changes are also applied in-memory immediately via SystemSetting.apply_smtp!

Rails.application.config.after_initialize do
  SystemSetting.apply_smtp!
rescue StandardError => e
  Rails.logger.warn "[SMTP] Could not apply settings from DB: #{e.message}"
end
