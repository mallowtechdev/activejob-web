# frozen_string_literal: true

module Activejob
  module Web
    class JobExecution < ApplicationRecord
      enum status: {
        requested: 0,
        approved: 1,
        rejected: 2,
        executed: 3,
        cancelled: 4,
        succeeded: 5,
        failed: 6
      }

      # == Validations =========================================================================================================
      validate :validate_approvers
      validate :validate_arguments
      validates :requestor_comments, presence: true
      validates :executor, presence: true

      # == Scopes =========================================================================================================
      scope :requested, -> { where(status: 'requested') }

      # == Callbacks =========================================================================================================
      after_initialize :set_default_status
      after_create :create_execution_history
      after_create :send_job_approval_request

      # == Associations =========================================================================================================
      belongs_to :job
      belongs_to :executor, foreign_key: 'requestor_id'
      has_one_attached :input_file
      has_many :job_approval_requests
      has_many :job_execution_histories

      # == Methods =========================================================================================================
      def create_execution_history
        job_execution_histories.update_all(is_current: false)
        history = Activejob::Web::JobExecutionHistory.create(
          job_execution_id: id,
          job_id:,
          arguments:,
          details: JSON.parse(to_json),
          is_current: true
        )

        history.input_file.attach(input_file.blob) if input_file.attached?
      end

      def update_execution_history
        current_execution_history&.update(details: JSON.parse(to_json))
      end

      def send_job_approval_request
        job.approvers.each do |approver|
          Activejob::Web::JobApprovalRequest.create(job_execution_id: id, approver_id: approver.id)
        end
      end

      def remove_create_approvals
        send_job_approval_request if job_approval_requests.destroy_all && !cancelled?
      end

      def gen_reqs_and_histories(reinitiate: false)
        if cancelled? || reinitiate
          update_execution_history
        else
          create_execution_history
        end

        remove_create_approvals
        true
      rescue StandardError => e
        Rails.logger.info "Error in JobExecution gen_reqs_and_histories: ID: #{id} Error: #{e.message}"
        false
      end

      def cancel_execution
        status == 'requested' || (status == 'approved' && execution_started_at.nil?)
      end

      def requested?
        status == 'requested'
      end

      def approved?
        (requested? && job.minimum_approvals_required.zero?) || status == 'approved'
      end

      def cancelled?
        status == 'cancelled'
      end

      def executed?
        status == 'executed'
      end

      def live_log?
        executed? && Activejob::Web.aws_credentials_present?
      end

      def execute
        return unless approved?

        update_columns(status: 'executed')
        initiate_job_execution
        update_execution_history
      end

      def self.update_job_execution_status(response)
        job_execution = Activejob::Web::JobExecution.find_by(active_job_id: response.job_id)
        execution_status = response.rescued_exception.present? ? 'failed' : 'succeeded'
        job_execution.update_columns(status: execution_status,
                                     execution_started_at: response.enqueued_at,
                                     run_at: response.scheduled_at,
                                     reason_for_failure: response.rescued_exception[:message])

        job_execution.update_execution_history
      end

      def current_execution_history
        job_execution_histories.find_by(is_current: true)
      end

      private

      def set_default_status
        self.status ||= :requested
      end

      def validate_approvers
        return if job.approvers.count >= job.minimum_approvals_required

        errors.add(:base, "Minimum Job Approver required is #{job.minimum_approvals_required}")
      end

      def initiate_job_execution
        values = arguments.values
        active_job = "Activejob::Web::#{job.job_name}".constantize.set(wait: 5.seconds).perform_later(*values)
        update_columns(active_job_id: active_job.job_id)
      rescue StandardError => e
        update_columns(status: 'failed', reason_for_failure: e.message)
      end

      def validate_arguments
        job_arguments = job.input_arguments
        arguments.each do |key, value|
          job_arg_regex = get_regex_for_key(key, job_arguments)
          next if job_arg_regex.nil? || value.match?(Regexp.new(job_arg_regex.first))

          errors.add(:base, "Input argument #{key} does not match regex '#{job_arg_regex.last}'")
        end
      end

      def get_regex_for_key(key, job_args)
        job_arg = job_args.find { |arg| arg['name'] == key }
        return nil unless job_arg

        job_arg['allowed_characters']
      end
    end
  end
end
