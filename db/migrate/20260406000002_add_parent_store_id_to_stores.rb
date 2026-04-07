class AddParentStoreIdToStores < ActiveRecord::Migration[8.1]
  def change
    add_column :stores, :parent_store_id, :uuid
    add_index  :stores, :parent_store_id
    add_foreign_key :stores, :stores, column: :parent_store_id
  end
end
