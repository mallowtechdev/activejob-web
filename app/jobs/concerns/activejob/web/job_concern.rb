# frozen_string_literal: true

module Activejob
  module Web
    module JobConcern
      extend ActiveSupport::Concern

      included do
        queue_as :default

        attr_accessor :job_execution_history
        attr_accessor :rescued_exception
        attr_accessor :activejob_web_logger

        before_perform :set_job_execution_history, :set_logger, only: :perform
        around_perform :set_timeout, only: :perform
        after_perform :update_job_executions, only: :perform
        after_perform :print_end_log, only: :perform

        def update_job_executions
          Activejob::Web::JobExecution.update_job_execution_status(self)
        end
      end

      private

      def set_job_execution_history
        self.job_execution_history = Activejob::Web::JobExecution.find_by(active_job_id: job_id).current_execution_history
      end

      def set_logger
        self.rescued_exception = {}
        self.activejob_web_logger = job_logger(job_execution_history.log_stream_name)
        activejob_web_logger.info "=================================== JOB STARTED ==================================="
      end

      def job_logger(log_stream_name)
        if Activejob::Web.aws_credentials_present?
          CloudWatchLogger.new({
                                 access_key_id: Activejob::Web.aws_credentials[:access_key_id],
                                 secret_access_key: Activejob::Web.aws_credentials[:secret_access_key]
                               },
                               Activejob::Web.aws_credentials[:cloudwatch_log_group],
                               log_stream_name,
                               { http_open_timeout: 10, http_read_timeout: 10 })
        else
          FileUtils.mkdir_p('log/activejob_web/job_executions')
          ActiveSupport::Logger.new(Rails.root.join("log/activejob_web/job_executions/#{log_stream_name}.log"))
        end
      end

      def set_timeout(&)
        Timeout.timeout(job_execution_history.job.max_run_time, &)
      rescue StandardError => e
        self.rescued_exception = { message: "Error in Activejob Web JobExecution - #{e.message}" }
        activejob_web_logger.info "Error in Activejob Web Job Execution - #{e.message}"
        update_job_executions
      end

      def print_end_log
        activejob_web_logger.info "=================================== JOB ENDED ==================================="
      end
    end
  end
end
