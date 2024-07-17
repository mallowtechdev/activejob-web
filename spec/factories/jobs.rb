# frozen_string_literal: true

FactoryBot.define do
  factory :job, class: Activejob::Web::Job do
    title { 'Activejob' }
    description { 'Web Gem' }
    job_name { 'TestJob' }
  end
end
