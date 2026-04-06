module Deals
  class IngredientMatcher
    # Matches unmatched deals to ingredients by finding the longest ingredient
    # name that appears as a substring in the deal name (case-insensitive).
    # Longest-match wins so "Chicken Breast" beats "Chicken" for the same deal.
    def match(scope = Deal.unmatched.active)
      matched = 0

      scope.find_each do |deal|
        ingredient = best_ingredient_match(deal.name)
        next unless ingredient

        deal.update!(ingredient: ingredient)
        matched += 1
      end

      matched
    end

    private

    def best_ingredient_match(deal_name)
      Ingredient
        .where("LOWER(?) LIKE LOWER('%' || name || '%')", deal_name)
        .order(Arel.sql("LENGTH(name) DESC"))
        .first
    end
  end
end
