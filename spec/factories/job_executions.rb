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

  factory :job_execution_with_attachment, class: Activejob::Web::JobExecution do
    requestor_comments { 'Requestor comments' }
    arguments { { sample_number: '123' } }
    status { 0 }
    reason_for_failure { nil }
    auto_execute_on_approval { false }
    run_at { nil }
    execution_started_at { nil }
    after(:build) do |job_execution_with_attachment|
      job_execution_with_attachment.input_file.attach(io: File.open(Rails.root.join('..', '..').expand_path.join('spec', 'fixtures', 'files', 'lorem_ipsum.jpg')), filename: 'lorem_ipsum.jpg', content_type: 'image/jpeg')
    end
  end

  factory :job_execution_two, class: Activejob::Web::JobExecution do
    requestor_comments { 'Requestor comments Two' }
    arguments { { sample_number: '123' } }
    status { 0 }
    reason_for_failure { nil }
    auto_execute_on_approval { false }
    run_at { nil }
    execution_started_at { nil }
  end
end
