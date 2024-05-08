# frozen_string_literal: true

module Activejob
  module Web
    module Authorization
      READ = %i[index show].freeze
      CREATE = %i[new create].freeze
      UPDATE = %i[edit update].freeze
      DESTROY = %i[destroy].freeze

      JOB_FULL_ACCESS = READ + CREATE + UPDATE
      JOB_EXECUTION_FULL_ACCESS = READ + CREATE + UPDATE + %i[cancel reinitiate execute logs history].freeze
      JOB_APPROVAL_FULL_ACCESS = READ + CREATE + UPDATE

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
        permissions = PERMISSIONS.fetch(user.activejob_web_role, {})
        permissions[resource.to_sym]&.include?(action.to_sym)
      end
    end
  end
end
