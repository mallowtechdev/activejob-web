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

    private

    def set_default_status
      self.status ||= :requested
    end
  end
end

# == Callbacks =========================================================================================================
def send_job_approval_request
  job.approvers.each do |approver|
    job_approval_requests.create(job_execution_id: id, approver_id: approver.id)
  end
end
