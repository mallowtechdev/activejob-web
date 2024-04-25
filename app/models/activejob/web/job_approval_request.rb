# frozen_string_literal: true

module Activejob
  module Web
    class JobApprovalRequest < ApplicationRecord
      enum response: {
        rejected: 0,
        approved: 1
      }

      # == Validations ===============================================================================================
      validates :approver_comments, presence: true

      # == Associations ==================================================================================================
      belongs_to :approver
      belongs_to :job_execution

      # == Associations ==================================================================================================
      scope :approved_requests, -> { where(response: %w[approved]) }
      scope :rejected_requests, -> { where(response: %w[rejected]) }
      scope :pending_requests, lambda { |admin, approver_id|
        where(admin ? { response: nil } : { approver_id:, response: nil })
      }

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
        if job_execution_requests.approved_requests.count >= job.minimum_approvals_required
          job_execution.update_columns(status: 'approved')
          job_execution.execute if job_execution.auto_execute_on_approval
        else
          job_status = execution_rejected? ? 'rejected' : 'requested'
          job_execution.update_columns(status: job_status)
        end
      end

      def execution_rejected?
        possible_requests = job_execution_requests.count - job_execution_requests.rejected_requests.count
        possible_requests < job.minimum_approvals_required
      end
    end
  end
end
