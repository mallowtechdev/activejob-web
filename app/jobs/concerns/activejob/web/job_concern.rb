# frozen_string_literal: true

module Activejob
  module Web
    module JobConcern
      extend ActiveSupport::Concern

      included do
        queue_as :default

        attr_accessor :job_execution
        attr_accessor :rescued_exception
        attr_accessor :activejob_web_logger

        before_perform :set_job_execution, :set_logger, only: :perform
        around_perform :set_timeout, only: :perform
        after_perform :update_job_executions, only: :perform

        def update_job_executions
          Activejob::Web::JobExecution.update_job_execution_status(self)
        end
      end

      private

      def set_job_execution
        self.job_execution = Activejob::Web::JobExecution.find_by(active_job_id: job_id)
      end

      def set_logger
        self.rescued_exception = {}
        self.activejob_web_logger = job_logger(job_execution)
        activejob_web_logger.info '===================== JOB START ======================'
      end

      def job_logger(job_execution)
        if Activejob::Web.aws_credentials_present?
          CloudWatchLogger.new({
                                 access_key_id: Activejob::Web.aws_credentials[:access_key_id],
                                 secret_access_key: Activejob::Web.aws_credentials[:secret_access_key]
                               },
                               Activejob::Web.aws_credentials[:cloudwatch_log_group],
                               "#{job_execution.id}_#{job_execution.job_id}",
                               { http_open_timeout: 10, http_read_timeout: 10 })
        else
          ActiveSupport::Logger.new(Rails.root.join("log/#{job_execution.id}_#{job_execution.job_id}.log"))
        end
      end

      def set_timeout(&)
        Timeout.timeout(job_execution.job.max_run_time, &)
      rescue StandardError => e
        self.rescued_exception = { message: "Error in Activejob Web JobExecution - #{e.message}" }
        activejob_web_logger.info "Error in Activejob Web Job Execution - #{e.message}"
        update_job_executions
      end
    end
  end
end
