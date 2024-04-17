# frozen_string_literal: true

module Activejob
  module Web
    module JobsHelper
      def job_execution_status_keys
        return [@job_execution.status] if @job_execution.new_record?

        approver? ? Activejob::Web::JobExecution.statuses.keys : [@job_execution.status]
      end

      def common_model?
        Activejob::Web.is_common_model
      end
    end
  end
end
