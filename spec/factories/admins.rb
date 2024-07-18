# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: Activejob::Web::Admin do
    email { 'admin@gmail.com' }
    name { 'Admin' }
  end
end
