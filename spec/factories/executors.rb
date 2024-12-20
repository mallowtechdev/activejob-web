# frozen_string_literal: true

FactoryBot.define do
  factory :executor, class: Activejob::Web::Executor do
    email { 'executor@gmail.com' }
    name { 'Executor' }
    password { 'password@123' }
  end

  factory :executor_one, class: Activejob::Web::Executor do
    email { 'executor.one@gmail.com' }
    name { 'Executor One' }
    password { 'password@123' }
  end
end
