class FetchDealsJob < ApplicationJob
  queue_as :default

  # chain: (optional) limit scraping to one chain, e.g. "publix".
  # store_id: (optional) limit to a single specific store record.
  # Pass nothing to scrape all stale scrapeable stores across all chains.
  def perform(store_id: nil, chain: nil)
    stores = if store_id
      Store.scrapeable.where(id: store_id)
    elsif chain
      Store.scrapeable.by_chain(chain).select(&:deals_stale?)
    else
      Store.scrapeable.select(&:deals_stale?)
    end

    # Deduplicate: group stores by their scrape_url so the same page isn't
    # hit multiple times. When per-store URLs are configured each store will
    # have a unique URL and will be scraped independently.
    stores.group_by(&:scrape_url).each do |url, url_stores|
      representative = url_stores.first
      scraper = scraper_for(representative)
      next unless scraper

      count = scraper.call
      Rails.logger.info("[FetchDealsJob] #{url}: #{count} deals upserted (#{url_stores.map(&:name).join(', ')})")

      # Mark all stores sharing this URL as freshly fetched.
      Store.where(id: url_stores.map(&:id)).update_all(deals_fetched_at: Time.current)
    end

    MatchDealsToIngredientsJob.perform_later
  end

  private

  def scraper_for(store)
    case store.chain
    when "publix" then Scrapers::PublixScraper.new(store)
    when "kroger"
      if store.store_number.blank?
        Rails.logger.warn("[FetchDealsJob] Skipping Kroger store #{store.id} (#{store.name}): store_number not set. " \
                          "Find the locationId via GET https://api.kroger.com/v1/locations?filter.zipCode=XXXXX")
        nil
      else
        Scrapers::KrogerScraper.new(store)
      end
    when "aldi"   then Scrapers::AldiScraper.new(store)
    else
      Rails.logger.warn("[FetchDealsJob] No scraper for chain: #{store.chain}")
      nil
    end
  end
end
