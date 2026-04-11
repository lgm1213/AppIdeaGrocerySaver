module ApplicationHelper
  include Pagy::Frontend

  # Returns a symbol describing the current state of a SolidQueue::Job.
  def job_execution_status(job)
    return :failed    if job.association(:failed_execution).loaded? ? job.failed_execution.present? : SolidQueue::FailedExecution.exists?(job_id: job.id)
    return :running   if job.association(:claimed_execution).loaded? ? job.claimed_execution.present? : SolidQueue::ClaimedExecution.exists?(job_id: job.id)
    return :queued    if job.association(:ready_execution).loaded? ? job.ready_execution.present? : SolidQueue::ReadyExecution.exists?(job_id: job.id)
    return :scheduled if SolidQueue::ScheduledExecution.exists?(job_id: job.id)
    return :completed if job.finished_at.present?

    :unknown
  end
  # Renders a freshness badge span for a chain card given a freshness symbol
  # (:fresh | :stale | :never | :unconfigured) returned by the controller.
  def chain_freshness_badge(freshness)
    case freshness
    when :fresh
      content_tag(:span, class: "admin-badge admin-badge-green") do
        content_tag(:span, "", style: "width:6px;height:6px;background:#16a34a;border-radius:50%;animation:pulse 2s ease-in-out infinite;") +
          " Fresh"
      end
    when :stale
      content_tag(:span, "Stale", class: "admin-badge admin-badge-yellow")
    when :never
      content_tag(:span, "Never synced", class: "admin-badge admin-badge-yellow")
    when :unconfigured
      content_tag(:span, "No store record", class: "admin-badge admin-badge-gray")
    end
  end

  # Extracts a short error message string from a SolidQueue::FailedExecution.
  # SolidQueue may return exec.error as an already-deserialized Hash or as a
  # raw JSON string depending on the adapter version — this handles both.
  def job_error_message(exec, truncate_to: 80)
    raw = exec.error
    hash = raw.is_a?(Hash) ? raw : (JSON.parse(raw) rescue nil)
    msg = hash&.dig("message") || raw.to_s
    msg.truncate(truncate_to)
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
