module Activejob
  module Web
    module SharedHelper
      def approver?
        return true if @activejob_web_current_user.parsed_class_name == 'Approver'

        @job.approver_ids.include?(@activejob_web_current_user.id)
      end

      def executor?
        return true if @activejob_web_current_user.parsed_class_name == 'Executor'

        @job.executor_ids.include?(@activejob_web_current_user.id)
      end

      def status_badge(status)
        case status
        when 'requested' then 'primary'
        when 'approved', 'executed', 'succeeded' then 'success'
        when 'cancelled' then 'secondary'
        when 'revoked' then 'info'
        when 'failed' then 'danger'
        when 'rejected' then 'warning'
        else
          'light'
        end
      end
    end
  end
end