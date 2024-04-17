# frozen_string_literal: true

module Activejob
  module Web
    module ApplicationHelper
      include Activejob::Web::SharedHelper

      def signed_in_as
        return 'Admin' if admin?

        type = @activejob_web_current_user.parsed_class_name
        if type == 'Common' && defined?(@job) && @job.present?
          approver? ? 'Approver' : 'Executor'
        else
          type == 'Common' ? 'User' : type
        end
      end
    end
  end
end
