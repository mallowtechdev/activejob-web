# frozen_string_literal: true

# spec/factories/job_approval_requests.rb
FactoryBot.define do
  factory :job_approval_request, class: Activejob::Web::JobApprovalRequest do
    job_execution_id { 1 }
    approver_id { 1 }
    response { 1 }
    approver_comments { 'Comments' }
  end
end
