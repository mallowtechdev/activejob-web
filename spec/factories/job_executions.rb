# frozen_string_literal: true

# spec/factories/job_executions.rb
FactoryBot.define do
  factory :job_execution, class: Activejob::Web::JobExecution do
    requestor_comments { 'Requestor comments' }
    arguments { { sample_number: '123' } }
    status { 0 }
    reason_for_failure { nil }
    auto_execute_on_approval { false }
    run_at { nil }
    execution_started_at { nil }
  end
end
