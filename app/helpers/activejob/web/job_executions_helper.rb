# frozen_string_literal: true

module Activejob
  module Web
    module JobExecutionsHelper
      include Activejob::Web::JobsHelper

      def argument_value(argument_name)
        return {} unless @job_execution.present? && @job_execution.arguments.present?

        @job_execution.arguments[argument_name]
      end

      def approval_request_details(job_execution)
        [
          job_execution.job_approval_requests.count,
          job_execution.job_approval_requests.approved_requests.count,
          job_execution.job_approval_requests.rejected_requests.count
        ]
      end

      def fetch_log_events(job_execution, page_token)
        response = job_execution.log_events(page_token)
        return [[], nil, nil] unless response.present?

        [response.events.map(&:message), response.next_backward_token, response.next_forward_token]
      end
    end
  end
end
