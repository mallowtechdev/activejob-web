# frozen_string_literal: true

FactoryBot.define do
  factory :job, class: ActivejobWeb::Job do
    title { 'Activejob' }
    description { 'Web Gem' }
  end
end
