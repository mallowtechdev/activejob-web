# frozen_string_literal: true

module Activejob
  module Web
    module JobExecutionsHelper
      include Activejob::Web::JobsHelper

      def argument_value(argument_name)
        return {} unless @job_execution.present? && @job_execution.arguments.present?

        @job_execution.arguments[argument_name]
      end

      def fetch_log_events(job_execution)
        job_execution.log_events.join("\n")
      end
    end
  end
end
