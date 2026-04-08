module Admin
  class JobExecutionsController < BaseController
    def index
      @status_filter = params[:status].presence || "all"

      base = SolidQueue::Job.order(created_at: :desc)

      @jobs = case @status_filter
      when "failed"
                base.joins(:failed_execution).includes(:failed_execution)
      when "running"
                base.joins(:claimed_execution)
                    .includes(claimed_execution: :process)
      when "queued"
                base.joins(:ready_execution).includes(:ready_execution)
      when "completed"
                base.where.not(finished_at: nil)
                    .where.not(id: SolidQueue::FailedExecution.select(:job_id))
      else
                base.includes(:ready_execution, :claimed_execution, :failed_execution)
      end.limit(100)

      @counts = {
        all:       SolidQueue::Job.count,
        running:   SolidQueue::ClaimedExecution.count,
        queued:    SolidQueue::ReadyExecution.count,
        failed:    SolidQueue::FailedExecution.count,
        completed: SolidQueue::Job.where.not(finished_at: nil)
                                  .where.not(id: SolidQueue::FailedExecution.select(:job_id))
                                  .count
      }
    end

    def show
      @job     = SolidQueue::Job.find(params[:id])
      @failed  = SolidQueue::FailedExecution.find_by(job_id: @job.id)
      @claimed = SolidQueue::ClaimedExecution.includes(:process).find_by(job_id: @job.id)
      @ready   = SolidQueue::ReadyExecution.find_by(job_id: @job.id)
      @arguments = parse_arguments(@job.arguments)
    end

    def retry
      @job    = SolidQueue::Job.find(params[:id])
      failed  = SolidQueue::FailedExecution.find_by!(job_id: @job.id)
      failed.retry
      redirect_to admin_job_execution_path(@job), notice: "Job re-enqueued successfully."
    end

    def destroy
      @job = SolidQueue::Job.find(params[:id])
      @job.failed_executions.destroy_all
      @job.destroy!
      redirect_to admin_job_executions_path, notice: "Job discarded."
    end

    private

    def parse_arguments(raw)
      return {} if raw.blank?

      # ActiveRecord may already deserialize the column to a Hash/Array
      return raw if raw.is_a?(Hash)
      return { raw: raw } if raw.is_a?(Array)

      parsed = JSON.parse(raw)
      parsed.is_a?(Hash) ? parsed : { raw: parsed }
    rescue JSON::ParserError
      { raw: raw.to_s }
    end
  end
end
