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
      validates :job_name, presence: true
      validate :validate_arguments, if: -> { new_record? && input_arguments.present? }
      validate :validate_approvers_executors, unless: :new_record?

      # == Callbacks =====================================================================================================
      after_initialize :set_default_queue

      private

      # Default value for queue
      def set_default_queue
        self.queue ||= 'default'
        self.max_run_time ||= 60
        self.minimum_approvals_required ||= 0
        self.priority ||= 1
      end

      def validate_arguments
        file_arguments = input_arguments.select { |arg| arg['type'] == "File" }
        errors.add(:base, "Duplicate 'File' types found.") if file_arguments.count > 1

        input_arguments.each do |arg|
          next unless arg.key?("allowed_characters")

          next if arg["allowed_characters"].count == 2

          errors.add(:base, "Invalid 'allowed_characters' input. Format must be ['<regex>', 'regex command']")
          break
        end
      end

      def validate_approvers_executors
        return unless minimum_approvals_required.positive?

        if approver_ids.count < minimum_approvals_required
          errors.add(:base, "Minimum Approver required is #{minimum_approvals_required}. Please select #{minimum_approvals_required - approver_ids.count} more approver(s).")
        end

        errors.add(:base, 'Approvers and Executors cannot be same.') if Activejob::Web.is_common_model && approver_ids.intersect?(executor_ids)
      end
    end
  end
end
