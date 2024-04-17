# frozen_string_literal: true

module Activejob
  module Web
    module Authorization
      READ = %i[index show].freeze
      CREATE = %i[new create].freeze
      UPDATE = %i[edit update].freeze
      DESTROY = %i[destroy].freeze

      JOB_EXECUTION_FULL = READ + CREATE + UPDATE + %i[cancel reinitiate].freeze

      PERMISSIONS = {
        admin: {
          jobs: READ + CREATE + UPDATE,
          job_executions: JOB_EXECUTION_FULL,
          job_approval_requests: READ + UPDATE
        },
        approver: {
          jobs: READ,
          job_approval_requests: READ + UPDATE
        },
        executor: {
          jobs: READ,
          job_executions: JOB_EXECUTION_FULL
        },
        common: {
          jobs: READ,
          job_executions: JOB_EXECUTION_FULL
        }
      }.freeze

      def self.authorized?(user, resource, action)
        puts "Authorized #{user.activejob_web_role} for #{resource} #{action}"
        role = user.activejob_web_role
        permissions = PERMISSIONS.fetch(role, {})
        puts "Permissions: #{permissions}"
        permissions[resource.to_sym]&.include?(action.to_sym)
      end
    end
  end
end
