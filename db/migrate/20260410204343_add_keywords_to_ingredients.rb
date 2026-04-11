class AddKeywordsToIngredients < ActiveRecord::Migration[8.1]
  def change
    add_column :ingredients, :keywords, :text, array: true, default: []

    # GIN index allows efficient Postgres array-containment queries.
    # Without it the keyword matcher would full-scan the ingredients table
    # on every deal being matched.
    add_index :ingredients, :keywords, using: :gin
  end
end
