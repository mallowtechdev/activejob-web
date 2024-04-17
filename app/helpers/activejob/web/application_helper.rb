# frozen_string_literal: true

module Activejob
  module Web
    module ApplicationHelper
      def signed_in_as
        if admin?
          'Admin'
        else
          type = @activejob_web_current_user.parsed_class_name
          type == 'Common' ? 'User' : type
        end
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
