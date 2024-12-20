# frozen_string_literal: true

module Activejob
  module Web
    module SharedHelper
      def approver?(user = activejob_web_current_user)
        return true if user.parsed_class_name == 'Approver'

        return false unless Activejob::Web.is_common_model

        if defined?(@job) && @job.present?
          user.approver_job_ids.include?(@job.id)
        else
          user.approver_jobs.exists?
        end
      end

      def executor?(user = activejob_web_current_user)
        return true if user.parsed_class_name == 'Executor'

        return false unless Activejob::Web.is_common_model

        if defined?(@job) && @job.present?
          user.executor_job_ids.include?(@job.id)
        else
          user.executor_jobs.exists?
        end
      end

      def status_badge(status)
        case status
        when 'requested' then 'primary'
        when 'approved', 'executed', 'succeeded' then 'success'
        when 'cancelled' then 'secondary'
        when 'failed' then 'danger'
        when 'rejected' then 'warning'
        else
          'light'
        end
      end
    end
  end
end
