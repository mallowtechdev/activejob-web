# spec/factories/job_executions.rb
FactoryBot.define do
  factory :job_execution, class: ActivejobWeb::JobExecution do
    requestor_id { 1 } # Adjust as needed
    job_id { SecureRandom.uuid } # Generates a random UUID
    requestor_comments { 'Requestor comments' }
    arguments { { key: 'value' } } # Example JSON structure, adjust as needed
    status { 0 } # Example status, adjust as needed
    reason_for_failure { 'Reason for failure' }
    auto_execute_on_approval { false }
    run_at { Time.current }
    execution_started_at { Time.current }
  end

  factory :valid_job_execution, class: ActivejobWeb::JobExecution do
    status { 'requested' }
    requestor_comments { 'joy' }
    auto_execute_on_approval { true }
  end

  factory :invalid_job_execution, class: ActivejobWeb::JobExecution do
    # This factory intentionally creates an invalid job execution with an invalid status
    status { 'approved' }
    auto_execute_on_approval { true }
  end
end
