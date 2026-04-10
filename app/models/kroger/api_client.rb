module Kroger
  # Thin wrapper around the Kroger Developer API (https://developer.kroger.com).
  # Uses OAuth2 client-credentials flow; tokens are cached for the lifetime of
  # this object (single scrape run), so one ApiClient instance per job is fine.
  #
  # Required env vars:
  #   KROGER_CLIENT_ID     — from developer.kroger.com app registration
  #   KROGER_CLIENT_SECRET — from developer.kroger.com app registration
  class ApiClient
    BASE_URL     = "https://api.kroger.com/v1".freeze
    TOKEN_URL    = "#{BASE_URL}/connect/oauth2/token".freeze
    PRODUCTS_URL = "#{BASE_URL}/products".freeze

    # Kroger returns max 50 products per call; paginate up to this many pages.
    PROMO_LIMIT = 50
    MAX_PAGES   = 20

    def initialize
      @client_id     = ENV.fetch("KROGER_CLIENT_ID")
      @client_secret = ENV.fetch("KROGER_CLIENT_SECRET")
      @token         = nil
      @token_expires_at = Time.at(0)
    end

    # Returns an array of promo-product hashes for the given Kroger locationId.
    #
    # Each hash:
    #   { name:, category:, upc:, size:, regular_price:, promo_price:, savings: }
    #
    # Raises if the store has no store_number set (that IS the locationId).
    def promo_products(location_id:)
      results    = []
      start_from = 1

      MAX_PAGES.times do
        page = fetch_products(location_id: location_id, start_from: start_from)
        data = page["data"] || []
        break if data.empty?

        data.each { |p| results << parse_product(p) }

        total      = page.dig("meta", "pagination", "total").to_i
        break if results.size >= total || data.size < PROMO_LIMIT

        start_from += PROMO_LIMIT
      end

      results.compact
    end

    private

    def fetch_products(location_id:, start_from:)
      params = {
        "filter.locationId" => location_id,
        "filter.on_promo"   => "true",
        "filter.limit"      => PROMO_LIMIT,
        "filter.start"      => start_from
      }
      get(PRODUCTS_URL, params)
    end

    def parse_product(raw)
      item  = Array(raw["items"]).first || {}
      price = item["price"] || {}

      promo_price   = price["promo"]&.to_f
      regular_price = price["regular"]&.to_f

      return nil if promo_price.nil?

      {
        name:          raw["description"].to_s.titleize,
        category:      Array(raw["categories"]).first,
        upc:           raw["upc"],
        size:          item["size"],
        regular_price: regular_price,
        promo_price:   promo_price,
        savings:       regular_price && promo_price ? (regular_price - promo_price).round(2) : nil
      }
    end

    # ── HTTP ──────────────────────────────────────────────────────────────────

    def get(url, params = {})
      response = connection.get(url) do |req|
        req.headers["Authorization"] = "Bearer #{access_token}"
        req.headers["Accept"]        = "application/json"
        params.each { |k, v| req.params[k] = v }
      end
      raise "Kroger API error (#{response.status}): #{response.body}" unless response.success?

      JSON.parse(response.body)
    end

    def access_token
      refresh_token! if @token.nil? || Time.current >= @token_expires_at
      @token
    end

    def refresh_token!
      response = connection.post(TOKEN_URL) do |req|
        req.headers["Content-Type"]  = "application/x-www-form-urlencoded"
        req.headers["Authorization"] = "Basic #{Base64.strict_encode64("#{@client_id}:#{@client_secret}")}"
        req.body = "grant_type=client_credentials&scope=product.compact"
      end
      raise "Kroger token error (#{response.status}): #{response.body}" unless response.success?

      data              = JSON.parse(response.body)
      @token            = data["access_token"]
      @token_expires_at = Time.current + data["expires_in"].to_i.seconds - 30.seconds
    end

    def connection
      @connection ||= Faraday.new do |f|
        f.options.timeout      = 30
        f.options.open_timeout = 10
      end
    end
  end
end
