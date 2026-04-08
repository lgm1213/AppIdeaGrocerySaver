module ApplicationHelper
  # Returns a symbol describing the current state of a SolidQueue::Job.
  def job_execution_status(job)
    return :failed    if job.association(:failed_execution).loaded? ? job.failed_execution.present? : SolidQueue::FailedExecution.exists?(job_id: job.id)
    return :running   if job.association(:claimed_execution).loaded? ? job.claimed_execution.present? : SolidQueue::ClaimedExecution.exists?(job_id: job.id)
    return :queued    if job.association(:ready_execution).loaded? ? job.ready_execution.present? : SolidQueue::ReadyExecution.exists?(job_id: job.id)
    return :scheduled if SolidQueue::ScheduledExecution.exists?(job_id: job.id)
    return :completed if job.finished_at.present?

    :unknown
  end
  # Returns true when any of the signed-in user's stores have been refreshed
  # more recently than the user last acknowledged new deals.
  def new_deals_available?
    user = Current.user
    return false unless user

    pref = user.user_preference
    return false unless pref

    last_seen = pref.deals_last_seen_at
    user.stores.any? do |store|
      # Non-scrapeable stores inherit freshness from their parent chain-wide store.
      source = store.canonical_store
      source.deals_fetched_at.present? &&
        (last_seen.nil? || source.deals_fetched_at > last_seen)
    end
  end
end
