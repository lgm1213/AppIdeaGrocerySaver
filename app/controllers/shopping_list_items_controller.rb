class ShoppingListItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_list
  before_action :set_item, only: %i[update destroy toggle]

  def create
    @item = @list.shopping_list_items.new(item_params)
    @item.position = @list.shopping_list_items.count

    if @item.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              "items_#{@item.category}",
              partial: "shopping_lists/item",
              locals: { item: @item }
            ),
            turbo_stream.replace(
              "list_progress",
              partial: "shopping_lists/progress",
              locals: { list: @list.reload }
            ),
            turbo_stream.replace("add_item_form", partial: "shopping_lists/add_item_form", locals: { list: @list })
          ]
        end
        format.html { redirect_to shopping_list_path(@list) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "add_item_form",
            partial: "shopping_lists/add_item_form",
            locals: { list: @list, item: @item }
          )
        end
        format.html { redirect_to shopping_list_path(@list), alert: @item.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @item.update(item_params)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "item_#{@item.id}",
          partial: "shopping_lists/item",
          locals: { item: @item }
        )
      end
      format.html { redirect_to shopping_list_path(@list) }
    end
  end

  def destroy
    @item.destroy!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("item_#{@item.id}"),
          turbo_stream.replace(
            "list_progress",
            partial: "shopping_lists/progress",
            locals: { list: @list.reload }
          )
        ]
      end
      format.html { redirect_to shopping_list_path(@list) }
    end
  end

  def toggle
    @item.toggle!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "item_#{@item.id}",
            partial: "shopping_lists/item",
            locals: { item: @item }
          ),
          turbo_stream.replace(
            "list_progress",
            partial: "shopping_lists/progress",
            locals: { list: @list.reload }
          )
        ]
      end
      format.html { redirect_to shopping_list_path(@list) }
    end
  end

  private

  def set_list
    @list = Current.user.shopping_lists.find(params[:shopping_list_id])
  end

  def set_item
    @item = @list.shopping_list_items.find(params[:id])
  end

  def item_params
    params.require(:shopping_list_item).permit(:name, :quantity, :unit, :category, :notes)
  end
end
