module Admin
  class JobsController < BaseController
    DISPATCHABLE = {
      "fetch_deals"    => { label: "Fetch Publix Deals",           job: FetchDealsJob,              description: "Scrapes the Publix weekly ad and upserts deals to the database." },
      "match_deals"    => { label: "Match Deals to Ingredients",   job: MatchDealsToIngredientsJob, description: "Links scraped deals to recipe ingredients by name similarity." },
      "full_pipeline"  => { label: "Full Pipeline (Fetch + Match)", job: FetchDealsJob,             description: "Runs the complete deal pipeline: scrape then match. Same as the Wednesday cron." }
    }.freeze

    def index
      @jobs = DISPATCHABLE
      load_activity
    end

    def status
      load_activity
      render layout: false
    end

    def create
      key = params[:job_key]
      config = DISPATCHABLE[key]

      if config.nil?
        redirect_to admin_jobs_path, alert: "Unknown job: #{key}"
        return
      end

      config[:job].perform_later
      redirect_to admin_jobs_path, notice: "#{config[:label]} enqueued successfully."
    end

    private

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
