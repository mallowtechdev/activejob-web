# frozen_string_literal: true

FactoryBot.define do
  factory :source_admin, class: 'User' do
    email { 'source_admin@gmail.com' }
    name { 'Source Admin' }
  end

  factory :source_approver, class: 'User' do
    email { 'source_approver@gmail.com' }
    name { 'Source Approver' }
  end

  factory :source_approver_two, class: 'User' do
    email { 'source_approver_two@gmail.com' }
    name { 'Source Approver Two' }
  end

  factory :source_executor, class: 'User' do
    email { 'source_executor@gmail.com' }
    name { 'Source Executor' }
  end

  factory :source_common, class: 'User' do
    email { 'source_common@gmail.com' }
    name { 'Source Common' }
  end

  factory :source_user, class: 'User' do
    email { 'source_user@gmail.com' }
    name { 'Source User' }
  end
end
