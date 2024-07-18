# frozen_string_literal: true

FactoryBot.define do
  factory :approver, class: Activejob::Web::Approver do
    email { 'approver@gmail.com' }
    name { 'Approver' }
    password { 'password@123' }
  end

  factory :approver_one, class: Activejob::Web::Approver do
    email { 'approver.one@gmail.com' }
    name { 'Approver One' }
    password { 'password@123' }
  end
end
