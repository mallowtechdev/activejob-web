# frozen_string_literal: true

module Activejob
  module Web
    module Authorization
      READ = %i[index show].freeze
      CREATE = %i[new create].freeze
      UPDATE = %i[edit update].freeze
      DESTROY = %i[destroy].freeze

      JOB_FULL_ACCESS = READ + CREATE + UPDATE
      JOB_EXECUTION_FULL_ACCESS = READ + CREATE + UPDATE + %i[cancel reinitiate].freeze
      JOB_APPROVAL_FULL_ACCESS = READ + CREATE

      PERMISSIONS = {
        admin: {
          jobs: JOB_FULL_ACCESS,
          job_executions: JOB_EXECUTION_FULL_ACCESS,
          job_approval_requests: JOB_APPROVAL_FULL_ACCESS
        },
        approver: {
          jobs: READ,
          job_approval_requests: JOB_APPROVAL_FULL_ACCESS
        },
        executor: {
          jobs: READ,
          job_executions: JOB_EXECUTION_FULL_ACCESS
        },
        common: {
          jobs: READ,
          job_executions: JOB_EXECUTION_FULL_ACCESS,
          job_approval_requests: JOB_APPROVAL_FULL_ACCESS

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
