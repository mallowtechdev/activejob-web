# frozen_string_literal: true

# spec/factories/job_execution_histories.rb
FactoryBot.define do
  factory :job_execution_history, class: Activejob::Web::JobExecutionHistory do
    log_stream_name { '0994edd6-63e8-4fdd-bf40-976d3aa9bc0f' }
    details { nil }
    arguments { nil }
    is_current { false }
  end
end
