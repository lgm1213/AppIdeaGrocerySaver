class PreferencesController < ApplicationController
  before_action :require_authentication
  before_action :require_onboarding_complete

  def show
    @preference         = Current.user.user_preference || Current.user.build_user_preference
    @user_stores        = Current.user.stores
  end

  def edit
    @preference         = Current.user.user_preference || Current.user.build_user_preference
    @available_stores   = Store.order(:name)
    @selected_store_ids = Current.user.stores.pluck(:id)
  end

  def update
    @preference = Current.user.user_preference || Current.user.build_user_preference

    if @preference.update(preference_params)
      sync_user_stores(params[:store_ids] || [])
      redirect_to preferences_path, notice: "Preferences saved."
    else
      @available_stores   = Store.order(:name)
      @selected_store_ids = Current.user.stores.pluck(:id)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def sync_user_stores(store_ids)
    selected = Store.where(id: store_ids).pluck(:id)

    Current.user.user_stores.where.not(store_id: selected).delete_all

    selected.each_with_index do |store_id, idx|
      Current.user.user_stores.find_or_create_by!(store_id: store_id) do |us|
        us.primary = idx.zero?
      end
    end

    if Current.user.user_stores.primary.none? && Current.user.user_stores.any?
      Current.user.user_stores.first.update!(primary: true)
    end
  end

  def preference_params
    params.require(:user_preference).permit(
      :household_size, :cooking_skill, :meal_complexity,
      :weekly_budget, :zip_code, :preferred_store,
      :meals_per_week, :include_breakfast, :include_lunch, :include_dinner,
      dietary_restrictions: [], preferred_cuisines: []
    )
  end
end
