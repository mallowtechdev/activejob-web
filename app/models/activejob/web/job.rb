# frozen_string_literal: true

module Activejob
  module Web
    class Job < ApplicationRecord
      self.primary_key = 'id'

      # == Associations ==================================================================================================

      has_and_belongs_to_many :approvers,
                              class_name: 'Activejob::Web::Approver',
                              join_table: 'activejob_web_job_approvers'
      has_and_belongs_to_many :executors,
                              class_name: 'Activejob::Web::Executor',
                              join_table: 'activejob_web_job_executors'

      has_many :job_executions
      has_one_attached :template_file

      # == Validations ===================================================================================================
      validates :title, presence: true, length: { maximum: 255 }
      validates :description, presence: true, length: { maximum: 1000 }
      validate :validate_approvers_executors

      # == Callbacks =====================================================================================================
      after_initialize :set_default_queue

      private

      # Default value for queue
      def set_default_queue
        self.queue ||= 'default'
      end

      def validate_approvers_executors
        return if minimum_approvals_required.zero?

        if approver_ids.count < minimum_approvals_required
          errors.add(:base, "Minimum Approver required is #{minimum_approvals_required}. Please select #{minimum_approvals_required - approver_ids.count} more approver(s).")
        end

        errors.add(:base, 'Approvers and Executors cannot be same.') if Activejob::Web.is_common_model && approver_ids.intersect?(executor_ids)
      end
    end
  end
end
