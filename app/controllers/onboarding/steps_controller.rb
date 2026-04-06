module Onboarding
  class StepsController < ApplicationController
    before_action :require_authentication
    before_action :redirect_if_complete

    layout "onboarding"

    # Step 1 — Dietary preferences & lifestyle
    def preferences
      @user_preference = current_preference
    end

    def update_preferences
      @user_preference = current_preference

      if @user_preference.update(preferences_params)
        Current.user.update!(onboarding_step: "budget_location")
        redirect_to onboarding_budget_location_path
      else
        render :preferences, status: :unprocessable_entity
      end
    end

    # Step 2 — Budget, location & store selection
    def budget_location
      @user_preference    = current_preference
      @available_stores   = Store.order(:name)
      @selected_store_ids = Current.user.stores.pluck(:id)
    end

    def update_budget_location
      @user_preference = current_preference

      if @user_preference.update(budget_location_params)
        sync_user_stores(params[:store_ids] || [])
        Current.user.update!(onboarding_step: "recap")
        redirect_to onboarding_recap_path
      else
        @available_stores   = Store.order(:name)
        @selected_store_ids = Current.user.stores.pluck(:id)
        render :budget_location, status: :unprocessable_entity
      end
    end

    # Step 3 — Recap / confirm
    def recap
      @user_preference = Current.user.user_preference
    end

    def complete
      Current.user.update!(onboarding_step: "complete", onboarding_complete: true)
      redirect_to onboarding_success_path
    end

    # Step 4 — Success
    def success
    end

    private

    def redirect_if_complete
      redirect_to dashboard_path if Current.user.onboarding_complete?
    end

    def current_preference
      Current.user.user_preference || Current.user.create_user_preference!
    end

    # Replace the user's store associations with the submitted selection
    def sync_user_stores(store_ids)
      selected = Store.where(id: store_ids).pluck(:id)

      Current.user.user_stores.where.not(store_id: selected).delete_all

      selected.each_with_index do |store_id, idx|
        Current.user.user_stores.find_or_create_by!(store_id: store_id) do |us|
          us.primary = idx.zero?
        end
      end

      # Make the first selected store primary if none is set
      if Current.user.user_stores.primary.none? && Current.user.user_stores.any?
        Current.user.user_stores.first.update!(primary: true)
      end
    end

    def preferences_params
      params.require(:user_preference).permit(
        :household_size,
        :cooking_skill,
        :meals_per_week,
        :meal_complexity,
        :include_breakfast,
        :include_lunch,
        :include_dinner,
        dietary_restrictions: [],
        preferred_cuisines: []
      )
    end

    def budget_location_params
      params.require(:user_preference).permit(
        :weekly_budget,
        :zip_code,
        :preferred_store
      )
    end
  end
end
