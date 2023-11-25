# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    email { 'user@gmail.com' }
    name { 'user' }
    password { 'password@123' }
  end

  factory :approver, class: User do
    email { 'testapprover@gmail.com' }
    name { 'Test approver' }
    password { 'password@123' }
  end

  factory :approver1, class: User do
    email { 'testapprover1@gmail.com' }
    name { 'First approver' }
    password { 'password@123' }
  end

  factory :executor, class: User do
    email { 'testexecutor@gmail.com' }
    name { 'Test executor' }
    password { 'password@123' }
  end

  factory :executor1, class: User do
    email { 'testexecutor1@gmail.com' }
    name { 'First executor' }
    password { 'password@123' }
  end
end
