# frozen_string_literal: true

FactoryBot.define do
  factory :job, class: Activejob::Web::Job do
    title { 'Activejob' }
    description { 'Web Gem' }
    job_name { 'TestJob' }
    input_arguments do
      [{ name: 'sample_number',
         type: 'Integer',
         required: true,
         allowed_characters: { 'regex' => /\A[-+]?\d+(\.\d+)?\z/, 'description' => 'String Regex' } }]
    end
    queue { 'default' }
    max_run_time { 60 }
    minimum_approvals_required { 0 }
    priority { 0 }
  end

  factory :job_two, class: Activejob::Web::Job do
    title { 'Activejob 2' }
    description { 'Web Gem 2' }
    job_name { 'TestJob2' }
  end
end
