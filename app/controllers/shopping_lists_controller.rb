class ShoppingListsController < ApplicationController
  before_action :require_authentication
  before_action :require_onboarding_complete
  before_action :set_list, only: %i[show destroy mark_complete]

  def index
    @lists   = Current.user.shopping_lists.recent
    @active  = @lists.select(&:active?)
    @done    = @lists.reject(&:active?)
  end

  def show
    @items_by_category = @list.items_by_category
    @deal_map          = build_deal_map
  end

  def new
    @list       = Current.user.shopping_lists.new
    @meal_plans = Current.user.meal_plans.active.recent
  end

  def create
    @list = Current.user.shopping_lists.new(list_params)

    if @list.save
      redirect_to shopping_list_path(@list), notice: "Shopping list created."
    else
      @meal_plans = Current.user.meal_plans.active.recent
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy!
    redirect_to shopping_lists_path, notice: "List deleted."
  end

  def mark_complete
    @list.mark_complete!
    respond_to do |format|
      format.html { redirect_to shopping_list_path(@list), notice: "List marked complete!" }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "list_status_#{@list.id}",
          partial: "shopping_lists/list_status",
          locals: { list: @list }
        )
      end
    end
  end

  def generate_from_plan
    meal_plan = Current.user.meal_plans.find(params[:meal_plan_id])
    list      = ShoppingList.generate_from_plan!(meal_plan, Current.user)
    redirect_to shopping_list_path(list),
                notice: "Shopping list generated! #{list.total_items} items added."
  rescue ActiveRecord::RecordNotFound
    redirect_to shopping_lists_path, alert: "Meal plan not found."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to shopping_lists_path, alert: e.message
  end

  private

  def set_list
    @list = Current.user.shopping_lists.find(params[:id])
  end

  def build_deal_map
    ingredient_ids = @list.shopping_list_items.where.not(ingredient_id: nil).pluck(:ingredient_id)
    return {} if ingredient_ids.empty?

    stores = Current.user.stores
    return {} if stores.empty?

    Deal.where(store: stores, ingredient_id: ingredient_ids)
        .active
        .index_by(&:ingredient_id)
  end

  def list_params
    params.require(:shopping_list).permit(:name, :meal_plan_id, :shop_date, :notes)
  end
end
