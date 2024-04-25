# frozen_string_literal: true

module Activejob
  module Web
    module JobsHelper
      def common_model?
        !admin? && Activejob::Web.is_common_model
      end

      def job_count(user)
        user.jobs.count
      end

      def job_execution_count(user)
        if admin?
          Activejob::Web::JobExecution.count
        elsif executor?
          user.job_executions.count
        else
          0
        end
      end

      def job_approval_count(user)
        if admin?
          Activejob::Web::JobApprovalRequest.count
        elsif approver?
          user.job_approval_requests.count
        else
          0
        end
      end
    end
  end
end
