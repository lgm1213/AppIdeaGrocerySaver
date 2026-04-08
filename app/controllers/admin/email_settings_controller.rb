module Admin
  class EmailSettingsController < BaseController
    def show
      @settings = current_smtp_values
    end

    def edit
      @settings = current_smtp_values
    end

    def update
      SystemSetting::SMTP_KEYS.each do |key|
        value = params.dig(:email_settings, key)
        next if value.nil?
        # Don't overwrite password if field was left blank
        next if key == "smtp_password" && value.blank?

        SystemSetting[key] = value
      end

      # Apply to ActionMailer in-memory — no restart needed
      SystemSetting.apply_smtp!

      redirect_to admin_email_settings_path, notice: "Email settings saved and applied."
    end

    private

    def current_smtp_values
      SystemSetting::SMTP_KEYS.each_with_object({}) do |key, hash|
        hash[key] = SystemSetting[key]
      end
    end
  end
end
