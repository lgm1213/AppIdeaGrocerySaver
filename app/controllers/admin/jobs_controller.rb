module Admin
  class JobsController < BaseController
    # Per-chain visual config — add a row here whenever a new chain is supported.
    CHAIN_CONFIG = {
      "publix" => { label: "Publix", accent: "#16a34a", icon_bg: "#dcfce7", icon_color: "#15803d" },
      "kroger" => { label: "Kroger", accent: "#2563eb", icon_bg: "#dbeafe", icon_color: "#1d4ed8" },
      "aldi"   => { label: "Aldi",   accent: "#d97706", icon_bg: "#fef3c7", icon_color: "#b45309" }
    }.freeze

    # Jobs available per chain card.
    CHAIN_JOBS = [
      { key: "fetch_deals", label: "Fetch Weekly Deals",
        description: "Scrape the weekly ad and upsert deals." },
      { key: "match_deals", label: "Match Ingredients",
        description: "Link deals to recipe ingredients." }
    ].freeze

    # Cross-chain global operations shown below the cards.
    GLOBAL_JOBS = {
      "full_pipeline" => {
        label:       "Full Pipeline — All Chains",
        job:         FetchDealsJob,
        description: "Fetches every scrapeable chain then runs ingredient matching. " \
                     "Same as the Wednesday cron."
      }
    }.freeze

    def index
      chain_stores = Store.where(parent_store_id: nil).index_by(&:chain)

      @chain_data = CHAIN_CONFIG.map do |key, config|
        store     = chain_stores[key]
        freshness = chain_freshness(store)
        jobs      = chain_jobs_for(key, store)
        { key: key, store: store, freshness: freshness, jobs: jobs, **config }
      end

      load_activity
    end

    def status
      load_activity
      render layout: false
    end

    def create
      chain = params[:chain].presence
      key   = params[:job_key]

      label = dispatch_job(key, chain)
      if label
        redirect_to admin_jobs_path, notice: "#{label} enqueued successfully."
      else
        redirect_to admin_jobs_path, alert: "Unknown job: #{key}"
      end
    end

    private

    # Returns :fresh | :stale | :never | :unconfigured for a chain-wide store.
    def chain_freshness(store)
      return :unconfigured       if store.nil?
      return :never              if store.deals_fetched_at.nil?
      return :stale              if store.deals_stale?
      :fresh
    end

    # Returns the list of job descriptors for a chain card, annotated with
    # whether they are currently dispatchable.
    def chain_jobs_for(chain_key, store)
      CHAIN_JOBS.map do |job|
        needs_setup = chain_key == "kroger" &&
                      job[:key] == "fetch_deals" &&
                      store&.store_number.blank?

        job.merge(
          dispatchable:  !needs_setup,
          setup_hint:    needs_setup ? "Needs store_number (Kroger locationId)" : nil
        )
      end
    end

    def dispatch_job(key, chain)
      case key
      when "fetch_deals"
        FetchDealsJob.perform_later(chain: chain)
        chain ? "#{CHAIN_CONFIG.dig(chain, :label)} — Fetch Weekly Deals" : "Fetch Weekly Deals (All Chains)"
      when "match_deals"
        MatchDealsToIngredientsJob.perform_later
        "Match Ingredients"
      when "full_pipeline"
        FetchDealsJob.perform_later
        GLOBAL_JOBS["full_pipeline"][:label]
      end
    end

    def load_activity
      return unless SolidQueue::Job.table_exists?

      @running   = SolidQueue::ClaimedExecution.includes(:job)
                                               .order(created_at: :desc)
                                               .limit(10)
      @queued    = SolidQueue::ReadyExecution.includes(:job)
                                             .order(created_at: :desc)
                                             .limit(10)
      @completed = SolidQueue::Job.where.not(finished_at: nil)
                                  .where(finished_at: 30.minutes.ago..)
                                  .order(finished_at: :desc)
                                  .limit(20)
      @failed    = SolidQueue::FailedExecution.includes(:job)
                                              .order(created_at: :desc)
                                              .limit(10)
      @processes = SolidQueue::Process.order(created_at: :desc).limit(5)
      @queue_available = true
    rescue StandardError
      @queue_available = false
    end
  end
end
