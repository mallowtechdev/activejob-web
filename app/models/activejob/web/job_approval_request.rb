# frozen_string_literal: true

module Activejob
  module Web
    class JobApprovalRequest < ApplicationRecord
      enum response: {
        rejected: 0,
        approved: 1,
        revoked: 2
      }

      # == Associations ==================================================================================================
      belongs_to :approver
      belongs_to :job_execution

      # == Associations ==================================================================================================
      scope :approved_requests, -> { where(response: %w[approved revoked]) }

      # == Callbacks ==================================================================================================
      after_update :update_job_execution_status

      # == Methods ==================================================================================================
      def job
        job_execution.job
      end

      private

      def job_execution_requests
        job_execution.job_approval_requests
      end

      def update_job_execution_status
        return unless job_execution_requests.approved_requests.count >= job.minimum_approvals_required

        job_execution.update(status: 'approved')
        return unless job_execution.auto_execute_on_approval

        job_execution.execute(Time.now.utc)
      end
    end
  end
end
