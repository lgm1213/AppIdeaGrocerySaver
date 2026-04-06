class FetchDealsJob < ApplicationJob
  queue_as :default

  # Pass a store_id to scrape one store, or nil to scrape all stale stores.
  def perform(store_id = nil)
    stores = store_id ? Store.where(id: store_id) : Store.all.select(&:deals_stale?)

    stores.each do |store|
      scraper = scraper_for(store)
      next unless scraper

      count = scraper.call
      Rails.logger.info("[FetchDealsJob] #{store.name}: #{count} deals upserted")
    end

    MatchDealsToIngredientsJob.perform_later
  end

  private

  def scraper_for(store)
    case store.chain
    when "publix" then Scrapers::PublixScraper.new(store)
    else
      Rails.logger.warn("[FetchDealsJob] No scraper for chain: #{store.chain}")
      nil
    end
  end
end
