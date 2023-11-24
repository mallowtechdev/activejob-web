# frozen_string_literal: true

module ActivejobWeb
  class JobApprovalRequest < ApplicationRecord
    belongs_to :approver, class_name: Activejob::Web.job_approvers_class.to_s, foreign_key: 'approver_id'
    belongs_to :job_execution, class_name: 'ActivejobWeb::JobExecution', foreign_key: 'job_execution_id'
  end
end
