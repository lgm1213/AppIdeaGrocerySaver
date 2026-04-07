module ApplicationHelper
  # Returns true when any of the signed-in user's stores have been refreshed
  # more recently than the user last acknowledged new deals.
  def new_deals_available?
    user = Current.user
    return false unless user

    pref = user.user_preference
    return false unless pref

    last_seen = pref.deals_last_seen_at
    user.stores.any? do |store|
      # Non-scrapeable stores inherit freshness from their parent chain-wide store.
      source = store.canonical_store
      source.deals_fetched_at.present? &&
        (last_seen.nil? || source.deals_fetched_at > last_seen)
    end
  end
end
