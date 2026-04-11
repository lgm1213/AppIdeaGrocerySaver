module Deals
  # Matches unmatched deals to ingredients using two strategies:
  #
  # 1. Keyword expansion — checks the deal name against both the ingredient's
  #    canonical name AND its `keywords` array. This handles brand names that
  #    don't literally contain the ingredient name (e.g. "Dave's Killer Bread"
  #    still matches the ingredient "Whole Wheat Bread" via keyword "bread").
  #
  # 2. Category guard — uses Ingredient::CATEGORY_DEAL_HINTS to reject
  #    candidates whose category is incompatible with the deal's retailer
  #    category string. This eliminates false positives like ingredient
  #    "Chicken" matching a deal for "Swanson Chicken Broth 14oz".
  #
  # Ranking: the ingredient whose longest matching term (name or keyword)
  # appears in the deal name wins. Longer terms are more specific, so
  # "Chicken Breast" will beat "Chicken" for a "Tyson Chicken Breast" deal.
  class IngredientMatcher
    def match(scope = Deal.unmatched.active)
      matched = 0

      scope.find_each do |deal|
        ingredient = best_match_for(deal)
        next unless ingredient

        deal.update!(ingredient: ingredient)
        matched += 1
      end

      matched
    end

    private

    def best_match_for(deal)
      candidates = keyword_candidates(deal.name)
      return nil if candidates.empty?

      # Apply category guard. If every candidate is filtered out (e.g. the
      # scraper returned a blank or unexpected category string), fall back to
      # the unfiltered candidate list so we don't drop a valid match entirely.
      compatible = candidates.select { |i| i.category_compatible?(deal.category) }
      compatible = candidates if compatible.empty?

      compatible.max_by { |i| longest_match_length(i, deal.name) }
    end

    # Returns all ingredients where the deal name contains either the
    # ingredient's canonical name OR any of its keywords (case-insensitive).
    def keyword_candidates(deal_name)
      Ingredient
        .where(
          "LOWER(?) LIKE LOWER('%' || name || '%') OR " \
          "EXISTS (SELECT 1 FROM unnest(keywords) kw " \
          "        WHERE LOWER(?) LIKE LOWER('%' || kw || '%'))",
          deal_name, deal_name
        )
        .to_a
    end

    # Length of the longest term (name or keyword) from this ingredient that
    # actually appears in the deal name. Used to rank candidates so that more
    # specific ingredients win over generic ones.
    def longest_match_length(ingredient, deal_name)
      all_terms     = [ ingredient.name ] + Array(ingredient.keywords)
      downcased_deal = deal_name.downcase
      matching      = all_terms.select { |t| downcased_deal.include?(t.downcase) }
      matching.map(&:length).max || 0
    end
  end
end
