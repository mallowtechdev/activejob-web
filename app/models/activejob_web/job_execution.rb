# frozen_string_literal: true

module ActivejobWeb
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

    validates :requestor_comments, presence: true

    after_initialize :set_default_status
    after_save :send_job_approval_request

    belongs_to :job, class_name: 'ActivejobWeb::Job', foreign_key: 'job_id'
    has_many :job_approval_requests
    belongs_to :user, class_name: 'User', foreign_key: 'requestor_id'
    def response_count
      job_approval_requests.where(response: 1).count
    end
    def enqueue_job_if_approved
      if auto_execute_on_approval? && enough_approvals?
        # needs to enqueue the job with the job id and input arguments
        AutoEnqueueJob.perform_later(job.id, job.input_arguments)
      end
    end

    private
    def set_default_status
      self.status ||= :requested
    end
    def send_job_approval_request
      job.approvers.each do |approver|
        job_approval_requests.create(job_execution_id: id, approver_id: approver.id)
      end
    end

    def enough_approvals?
      response_count >= job.minimum_approvals_required
    end
  end
end