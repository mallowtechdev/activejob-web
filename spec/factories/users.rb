# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: User do
    email { 'admin@gmail.com' }
    name { 'Admin' }
    password { 'password@123' }
  end

  factory :user, class: User do
    email { 'user@gmail.com' }
    name { 'user' }
    password { 'password@123' }
  end

  factory :user_one, class: User do
    email { 'user.one@gmail.com' }
    name { 'User One' }
    password { 'password@123' }
  end

  factory :approver, class: User do
    email { 'approver@gmail.com' }
    name { 'Approver' }
    password { 'password@123' }
  end

  factory :approver_one, class: User do
    email { 'approver.one@gmail.com' }
    name { 'Approver One' }
    password { 'password@123' }
  end

  factory :executor, class: User do
    email { 'executor@gmail.com' }
    name { 'Executor' }
    password { 'password@123' }
  end

  factory :executor_one, class: User do
    email { 'executor.one@gmail.com' }
    name { 'Executor One' }
    password { 'password@123' }
  end
end
