# frozen_string_literal: true

FactoryBot.define do
  factory :approver, class: User do
    name { 'Test approver' }
  end

  factory :approver1, class: User do
    name { 'First approver' }
  end

  factory :executor, class: User do
    name { 'Test executor' }
  end

  factory :executor1, class: User do
    name { 'First executor' }
  end
end
