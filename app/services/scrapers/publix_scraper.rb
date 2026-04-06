module Scrapers
  class PublixScraper
    WEEKLY_AD_URL  = "https://www.publix.com/savings/weekly-ad/view-all".freeze
    CARD_SELECTOR  = '[data-qa="savings-weekly-card"]'.freeze
    LOAD_WAIT_SECS = 15

    def initialize(store)
      @store = store
    end

    def call
      deals_data = scrape
      upsert_deals(deals_data)
      @store.update!(deals_fetched_at: Time.current)
      deals_data.size
    end

    private

    def scrape
      browser = Ferrum::Browser.new(headless: true, timeout: 60)
      browser.goto(WEEKLY_AD_URL)

      # Wait for at least one deal card to appear, then give the rest time to render
      browser.network.wait_for_idle(duration: 2, timeout: 20) rescue nil
      sleep(LOAD_WAIT_SECS)

      raw = browser.evaluate(extraction_script)
      browser.quit

      Array(raw).map { |item| parse_deal(item) }.compact
    ensure
      browser&.quit rescue nil
    end

    def upsert_deals(deals_data)
      deals_data.each do |attrs|
        deal = @store.deals.find_or_initialize_by(publix_item_code: attrs[:publix_item_code])
        deal.assign_attributes(attrs)
        deal.save!
      end
    end

    # ── Parsing ──────────────────────────────────────────────────────────────

    def parse_deal(raw)
      badge        = raw["badge"].to_s.strip
      savings_text = raw["savings"].to_s.strip
      valid_text   = raw["validText"].to_s.strip

      deal_type, sale_price, unit, multi_qty = parse_badge(badge)
      savings_amount                         = parse_savings(savings_text)
      valid_from, valid_until                = parse_dates(valid_text)

      return nil if deal_type.nil?

      {
        publix_item_code: raw["itemCode"].to_s.presence,
        name:             raw["title"].to_s.strip,
        category:         raw["category"].to_s.presence,
        deal_type:        deal_type,
        badge_text:       badge,
        sale_price:       sale_price,
        savings_amount:   savings_amount,
        unit:             unit,
        multi_quantity:   multi_qty,
        valid_from:       valid_from,
        valid_until:      valid_until,
        raw_data:         raw
      }
    end

    def parse_badge(badge)
      case badge.downcase
      when /buy\s*1\s*get\s*1/
        [ "bogo", nil, nil, nil ]
      when /^(\d+)\s+for\s+\$([0-9.]+)/i
        qty   = Regexp.last_match(1).to_i
        price = Regexp.last_match(2).to_f
        [ "multi", price, nil, qty ]
      when /^\$([0-9.]+)\s*(lb|oz|ea|each|pk|pack)?/i
        price = Regexp.last_match(1).to_f
        u     = Regexp.last_match(2)&.downcase&.presence
        [ "sale", price, u, nil ]
      else
        nil
      end
    end

    def parse_savings(text)
      match = text.match(/\$([0-9.]+)/)
      match ? match[1].to_f : nil
    end

    def parse_dates(text)
      match = text.match(%r{(\d+)/(\d+)\s*-\s*(\d+)/(\d+)})
      return [ nil, nil ] unless match

      year = Date.current.year
      from = Date.new(year, match[1].to_i, match[2].to_i)
      to   = Date.new(year, match[3].to_i, match[4].to_i)

      # Handle year roll-over (e.g. 12/28 - 1/3)
      to = to.next_year if to < from

      [ from, to ]
    end

    # ── JavaScript extraction ─────────────────────────────────────────────────

    def extraction_script
      <<~JS
        (() => {
          const cards = document.querySelectorAll('[data-qa="savings-weekly-card"]');
          const results = [];

          cards.forEach(card => {
            const title    = card.querySelector('.title')?.textContent?.trim();
            const badge    = card.querySelector('.p-savings-badge')?.textContent?.trim();
            const savings  = card.querySelector('.additional-info')?.textContent?.trim();
            const itemCode = card.dataset.itemCode;

            const validEl = Array.from(card.querySelectorAll('span, p'))
                              .find(el => el.textContent.trim().match(/valid\\s+\\d/i));
            const validText = validEl?.textContent?.trim() || '';

            let category = null;
            let el = card;
            for (let i = 0; i < 8; i++) {
              el = el.parentElement;
              if (!el) break;
              if (el.className?.includes('category-section')) {
                category = el.querySelector('h2')?.textContent?.trim() || null;
                break;
              }
            }

            if (title && badge) {
              results.push({ itemCode, title, badge, savings, validText, category });
            }
          });

          return results;
        })()
      JS
    end
  end
end
