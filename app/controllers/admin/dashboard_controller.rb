module Admin
  class DashboardController < BaseController
    def index
      @user_count    = User.count
      @deal_count    = Deal.count
      @active_deals  = Deal.active.count
      @recipe_count  = Recipe.count
      @store_count   = Store.count
      @last_scraped  = Store.scrapeable.maximum(:deals_fetched_at)
      @smtp_configured = SystemSetting.smtp_configured?
    end
  end
end
