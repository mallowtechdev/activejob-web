# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: Activejob::Web::Admin do
    email { 'admin@gmail.com' }
    name { 'Admin' }
    password { 'password@123' }
    is_admin { true }
  end
end
