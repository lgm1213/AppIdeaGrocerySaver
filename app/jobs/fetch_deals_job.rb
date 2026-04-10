class FetchDealsJob < ApplicationJob
  queue_as :default

  # Pass a store_id to scrape one store, or nil to scrape all stale scrapeable stores.
  def perform(store_id = nil)
    stores = if store_id
      Store.scrapeable.where(id: store_id)
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
    when "kroger" then Scrapers::KrogerScraper.new(store)
    when "aldi"   then Scrapers::AldiScraper.new(store)
    else
      Rails.logger.warn("[FetchDealsJob] No scraper for chain: #{store.chain}")
      nil
    end
  end
end
