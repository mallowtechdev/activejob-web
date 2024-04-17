# frozen_string_literal: true

module Activejob
  module Web
    module JobsHelper
      def approver?
        @job.approver_ids.include?(@activejob_web_current_user.id)
      end

      def executor?
        @job.executor_ids.include?(@activejob_web_current_user.id)
      end

      def job_execution_status_keys
        return [@job_execution.status] if @job_execution.new_record?

        approver? ? Activejob::Web::JobExecution.statuses.keys : [@job_execution.status]
      end
    end
  end
end
