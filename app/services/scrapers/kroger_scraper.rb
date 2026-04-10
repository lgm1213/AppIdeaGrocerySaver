module Scrapers
  # Fetches active promotional deals from the Kroger Developer API.
  #
  # Prerequisites:
  #   1. Set KROGER_CLIENT_ID and KROGER_CLIENT_SECRET in env (developer.kroger.com).
  #   2. The Store record must have `store_number` set to the Kroger locationId.
  #      Find locationIds via: GET https://api.kroger.com/v1/locations?filter.zipCode=XXXXX
  #
  # Kroger's weekly ad runs Wednesday–Tuesday, so we default valid dates to the
  # current W–T window when the API does not return explicit expiry dates.
  class KrogerScraper
    def initialize(store)
      @store = store
    end

    def call
      location_id = @store.store_number.presence
      raise ArgumentError, "Store #{@store.id} (#{@store.name}) has no store_number; " \
                           "set it to the Kroger locationId before scraping." if location_id.nil?

      client     = Kroger::ApiClient.new
      products   = client.promo_products(location_id: location_id)
      deals_data = products.map { |p| build_deal(p) }.compact

      upsert_deals(deals_data)
      @store.update!(deals_fetched_at: Time.current)
      deals_data.size
    end

    private

    def build_deal(product)
      {
        name:           product[:name],
        category:       product[:category],
        deal_type:      "sale",
        badge_text:     "$#{product[:promo_price]}",
        sale_price:     product[:promo_price],
        savings_amount: product[:savings],
        unit:           product[:size],
        multi_quantity: nil,
        valid_from:     week_start,
        valid_until:    week_end,
        raw_data:       product
      }
    end

    def upsert_deals(deals_data)
      deals_data.each do |attrs|
        deal = @store.deals.find_or_initialize_by(
          name:        attrs[:name],
          valid_until: attrs[:valid_until]
        )
        deal.assign_attributes(attrs)
        deal.save!
      end
    end

    # Kroger weekly ad: Wednesday → Tuesday
    def week_start
      today = Date.current
      today.beginning_of_week(:wednesday)
    end

    def week_end
      week_start + 6.days
    end
  end
end
