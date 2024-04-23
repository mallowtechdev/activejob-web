module Activejob
  module Web
    module JobConcern
      extend ActiveSupport::Concern

      included do
        queue_as :default

        attr_accessor :rescued_exception
        attr_accessor :activejob_web_logger

        before_perform do |job|
          job.rescued_exception = {}
          job_execution = Activejob::Web::JobExecution.find_by(active_job_id: job.job_id)
          job.activejob_web_logger = ActiveSupport::Logger.new(Rails.root.join("log/#{job_execution.id}_#{job_execution.job_id}.log"))
          job.activejob_web_logger.info '===================== JOB START ======================'
        end

        after_perform :update_job_executions

        def update_job_executions
          Activejob::Web::JobExecution.update_job_execution_status(self)
        end
      end
    end
  end
end