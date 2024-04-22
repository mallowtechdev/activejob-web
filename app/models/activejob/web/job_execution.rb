# frozen_string_literal: true

module Activejob
  module Web
    class JobExecution < ApplicationRecord
      enum status: {
        requested: 0,
        approved: 1,
        rejected: 2,
        executed: 3,
        cancelled: 4,
        succeeded: 5,
        failed: 6
      }

      # == Validations =========================================================================================================
      validate :validate_approvers
      validates :requestor_comments, presence: true

      scope :requested, -> { where(status: 'requested') }
      # == Callbacks =========================================================================================================
      after_initialize :set_default_status
      after_create :send_job_approval_request

      # == Associations =========================================================================================================
      belongs_to :job
      belongs_to :executor, foreign_key: 'requestor_id'
      has_one_attached :input_file
      has_many :job_approval_requests

      # == Methods =========================================================================================================
      def send_job_approval_request
        job.approvers.each do |approver|
          Activejob::Web::JobApprovalRequest.create(job_execution_id: id, approver_id: approver.id)
        end
      end

      def cancel_execution
        (status == 'requested') || (status == 'approved' && execution_started_at.nil?)
      end

      def revoke_approval_requests
        job_approval_requests.where(response: 'approved').update_all(response: 'revoked')
      end

      def requested?
        status == 'requested'
      end

      def approved?
        status == 'approved'
      end

      def cancelled?
        status == 'cancelled'
      end

      def executed?
        status == 'executed'
      end

      def execute(start_time = Time.now.utc)
        return unless approved?

        update(status: 'executed')
        run_at = Time.now.utc
        begin
          initiate_job_execution
          update(status: 'succeeded', execution_started_at: start_time, run_at: run_at)
        rescue StandardError => e
          update(status: 'failed',
                 execution_started_at: start_time,
                 run_at: run_at,
                 reason_for_failure: e.message)
        end
      end

      private

      def set_default_status
        self.status ||= :requested
      end

      def validate_approvers
        return if job.approvers.count >= job.minimum_approvals_required

        errors.add(:base, "Minimum Job Approver required is #{job.minimum_approvals_required}.")
      end

      def initiate_job_execution
        job.job_name.constantize.perform_now('Dinesh', 'Suresh')
      end
    end
  end
end