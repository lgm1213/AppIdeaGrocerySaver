module Admin
  class SystemHealth
    def db_connected?
      ActiveRecord::Base.connection.execute("SELECT 1")
      true
    rescue StandardError
      false
    end

    def deals_stats
      {
        total:        Deal.count,
        active:       Deal.active.count,
        matched:      Deal.where.not(ingredient_id: nil).count,
        last_scraped: Store.scrapeable.maximum(:deals_fetched_at)
      }
    end

    def store_stats
      scrapeable = Store.scrapeable.to_a
      {
        total:     Store.count,
        scrapeable: scrapeable.count,
        stale:     scrapeable.count(&:deals_stale?)
      }
    end

    def user_stats
      {
        total:       User.count,
        onboarded:   User.where(onboarding_complete: true).count,
        with_stores: UserStore.distinct.count(:user_id),
        admins:      User.where(admin: true).count
      }
    end

    def recipe_stats
      {
        total:   Recipe.count,
        by_type: Recipe.group(:meal_type).count
      }
    end

    def queue_stats
      {
        jobs_table_exists: SolidQueue::Job.table_exists?,
        pending:           pending_jobs_count,
        failed:            failed_jobs_count,
        recent_completed:  recent_completed_jobs
      }
    rescue NameError
      { jobs_table_exists: false, pending: nil, failed: nil, recent_completed: [] }
    end

    private

    def pending_jobs_count
      SolidQueue::ReadyExecution.count
    rescue StandardError
      nil
    end

    def failed_jobs_count
      SolidQueue::FailedExecution.count
    rescue StandardError
      nil
    end

    def recent_completed_jobs
      []
    end
  end
end
