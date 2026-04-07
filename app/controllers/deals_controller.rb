class DealsController < ApplicationController
  before_action :require_authentication
  before_action :require_onboarding_complete
  before_action :set_deal, only: :show

  def index
    @user_stores = Current.user.stores
    base          = active_deals_scope

    @by_category  = base.group_by(&:category)
    @bogo_deals   = base.select { |d| d.deal_type == "bogo" }
    @matched      = matched_deals(base)

    Current.user.user_preference&.update!(deals_last_seen_at: Time.current)
  end

  def show; end

  private

  def set_deal
    @deal = active_deals_scope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to deals_path
  end

  def active_deals_scope
    stores = Current.user.stores
    return Deal.none if stores.empty?

    Deal.for_user_stores(stores).active.order(savings_amount: :desc)
  end

  def matched_deals(deals)
    return [] unless Current.user.user_preference&.preferred_store.present?

    preferred = Current.user.user_preference.preferred_store.downcase
    deals.select { |d| d.store.name.downcase.include?(preferred) }
  end
end
