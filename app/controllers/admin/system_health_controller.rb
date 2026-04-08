module Admin
  class SystemHealthController < BaseController
    def show
      health = Admin::SystemHealth.new
      @db_connected   = health.db_connected?
      @deals          = health.deals_stats
      @stores         = health.store_stats
      @users          = health.user_stats
      @recipes        = health.recipe_stats
      @queue          = health.queue_stats
      @smtp_configured = SystemSetting.smtp_configured?
      @rails_env      = Rails.env
      @ruby_version   = RUBY_VERSION
      @rails_version  = Rails.version
    end
  end
end
