module Scrapers
  # Scrapes the Aldi US weekly specials page using Ferrum (headless Chrome).
  #
  # ── Why not an API? ──────────────────────────────────────────────────────────
  # Aldi does not publish a public developer API. Their SPA calls an internal
  # GraphQL endpoint. The approach below avoids hard-coding Emotion CSS-in-JS
  # class names (which change on every build) and instead relies on:
  #   • data-* attributes / ARIA roles, which are more deploy-stable
  #   • Text-content pattern matching for prices
  #   • Structural DOM traversal (card boundary → heading → price leaf node)
  #
  # ── Finding better selectors when this breaks ────────────────────────────────
  # 1. Open https://www.aldi.us/en/weekly-specials/ in Chrome DevTools.
  # 2. Wait for the page to fully load (~10 s).
  # 3. In the Console tab run:
  #      document.querySelectorAll('[data-testid]').length
  #    If > 0, list them: [...document.querySelectorAll('[data-testid]')].map(e=>e.dataset.testid).filter((v,i,a)=>a.indexOf(v)===i)
  # 4. Alternatively intercept the GraphQL call:
  #      - Open Network tab → filter XHR/Fetch → reload
  #      - Look for a POST to a /graphql or /api endpoint returning product arrays
  #      - Extract the endpoint URL + Authorization header; adapt ApiClient approach
  # ─────────────────────────────────────────────────────────────────────────────
  class AldiScraper
    DEFAULT_URL    = "https://www.aldi.us/en/weekly-specials/".freeze
    LOAD_WAIT_SECS = 12

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
      browser.goto(@store.scrape_url || DEFAULT_URL)

      browser.network.wait_for_idle(duration: 2, timeout: 20) rescue nil
      sleep(LOAD_WAIT_SECS)

      raw = browser.evaluate(extraction_script)
      Array(raw).map { |item| parse_deal(item) }.compact
    ensure
      browser&.quit rescue nil
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

    def parse_deal(raw)
      name       = raw["name"].to_s.strip
      price_text = raw["price"].to_s.strip

      return nil if name.blank? || price_text.blank?

      deal_type, sale_price, unit, multi_qty = parse_price(price_text)
      valid_from, valid_until                = parse_dates(raw["validText"].to_s)

      return nil if deal_type.nil?

      {
        name:           name,
        category:       raw["category"].to_s.presence,
        deal_type:      deal_type,
        badge_text:     price_text,
        sale_price:     sale_price,
        savings_amount: parse_savings(raw["savings"].to_s),
        unit:           unit,
        multi_quantity: multi_qty,
        valid_from:     valid_from,
        valid_until:    valid_until,
        raw_data:       raw
      }
    end

    def parse_price(text)
      case text.downcase
      when /(\d+)\s+(?:for|\/)\s+\$([0-9.]+)/i
        qty   = Regexp.last_match(1).to_i
        price = Regexp.last_match(2).to_f
        [ "multi", price, nil, qty ]
      when /\$([0-9.]+)\s*(lb|oz|ea|each|pk|pack|ct)?/i
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
      match = text.match(%r{(\d+)/(\d+)\s*[-–]\s*(\d+)/(\d+)})
      return [ nil, nil ] unless match

      year = Date.current.year
      from = Date.new(year, match[1].to_i, match[2].to_i)
      to   = Date.new(year, match[3].to_i, match[4].to_i)
      to   = to.next_year if to < from

      [ from, to ]
    end

    # ── Extraction script ────────────────────────────────────────────────────
    # Avoids Emotion CSS-in-JS class names entirely.
    # Strategy:
    #   1. Walk every element with a [data-testid] attribute — many SPAs expose these.
    #   2. Fall back to article/li structural search with price-text detection.
    #   3. As a last resort, scan for any leaf element whose text matches a price
    #      pattern and walk up to find a product-card boundary.
    def extraction_script
      <<~JS
        (() => {
          const PRICE_RE = /^\$\d+\.?\d*$|^\d+\s+for\s+\$\d+(\.\d+)?$/i;

          // ── Pass 1: data-testid attributes (most stable across deploys) ──────
          const byTestId = (() => {
            const items = [];
            const cards = document.querySelectorAll(
              '[data-testid*="product"], [data-testid*="item"], [data-testid*="offer"]'
            );
            cards.forEach(card => {
              const nameEl  = card.querySelector('[data-testid*="name"], [data-testid*="title"], [data-testid*="description"]');
              const priceEl = card.querySelector('[data-testid*="price"], [data-testid*="amount"], [data-testid*="cost"]');
              if (nameEl && priceEl) {
                items.push({
                  name:  nameEl.textContent.trim(),
                  price: priceEl.textContent.trim(),
                  savings:   card.querySelector('[data-testid*="savings"], [data-testid*="discount"]')?.textContent?.trim() || '',
                  validText: card.querySelector('[data-testid*="valid"], [data-testid*="date"], [data-testid*="thru"]')?.textContent?.trim() || '',
                  category:  (() => {
                    let el = card;
                    for (let i = 0; i < 8; i++) {
                      el = el?.parentElement;
                      if (!el) break;
                      const h = el.querySelector(':scope > h2, :scope > h3');
                      if (h?.textContent?.trim()) return h.textContent.trim();
                    }
                    return null;
                  })()
                });
              }
            });
            return items;
          })();
          if (byTestId.length > 0) return byTestId;

          // ── Pass 2: aria-label / role="listitem" structural search ──────────
          const byRole = (() => {
            const items = [];
            // Product cards are commonly list items or articles
            const cards = document.querySelectorAll('article, li[role="listitem"], [role="listitem"]');
            cards.forEach(card => {
              // Price leaf: a single text node matching price pattern
              const allText = Array.from(card.querySelectorAll('*')).filter(el => {
                const t = el.childNodes.length === 1 && el.firstChild?.nodeType === 3
                  ? el.textContent.trim() : '';
                return PRICE_RE.test(t);
              });
              if (allText.length === 0) return;

              const priceEl = allText[0];
              const price   = priceEl.textContent.trim();

              // Name: the element with the most text that is NOT the price
              const textEls = Array.from(card.querySelectorAll('p, span, h3, h4'))
                .filter(el => !PRICE_RE.test(el.textContent.trim()) && el.textContent.trim().length > 3);
              const nameEl  = textEls[0];
              if (!nameEl) return;

              items.push({
                name:      nameEl.textContent.trim(),
                price:     price,
                savings:   '',
                validText: Array.from(card.querySelectorAll('span, p'))
                              .find(el => el.textContent.match(/valid|through|thru|\\d+\\/\\d+/i))
                              ?.textContent?.trim() || '',
                category:  null
              });
            });
            return items;
          })();
          if (byRole.length > 0) return byRole;

          // ── Pass 3: raw price-text scan (last resort) ──────────────────────
          const priceLeaves = Array.from(document.querySelectorAll('*')).filter(el => {
            const t = el.children.length === 0 ? el.textContent.trim() : '';
            return PRICE_RE.test(t) && el.getBoundingClientRect().height > 0;
          });

          const seen = new Set();
          return priceLeaves.flatMap(priceEl => {
            let card = priceEl;
            for (let i = 0; i < 6; i++) {
              card = card?.parentElement;
              if (!card) return [];
              if (card.getBoundingClientRect().height > 120) break;
            }
            if (!card || seen.has(card)) return [];
            seen.add(card);

            const price   = priceEl.textContent.trim();
            const textEls = Array.from(card.querySelectorAll('*'))
              .filter(el => el.children.length === 0 && !PRICE_RE.test(el.textContent.trim()) && el.textContent.trim().length > 3);
            const nameEl  = textEls[0];
            if (!nameEl) return [];

            return [{ name: nameEl.textContent.trim(), price, savings: '', validText: '', category: null }];
          });
        })()
      JS
    end
  end
end
