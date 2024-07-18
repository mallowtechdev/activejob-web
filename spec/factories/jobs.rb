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
    title { 'Activejob Two' }
    description { 'Web Gem Two' }
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

  factory :build_job, class: Activejob::Web::Job do
    title { 'Activejob Build Test' }
    description { 'Web Gem Build Test' }
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

  factory :default_value_job, class: Activejob::Web::Job do
    title { 'Activejob Default Value' }
    description { 'Web Gem Default Value' }
    job_name { 'TestJob2' }
  end
end
