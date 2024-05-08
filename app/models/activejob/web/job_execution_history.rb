module Activejob
  module Web
    class JobExecutionHistory < ApplicationRecord
      belongs_to :job
      belongs_to :job_execution

      def log_events(page_token = nil)
        aws_credentials = Aws::Credentials.new(Activejob::Web.aws_credentials[:access_key_id], Activejob::Web.aws_credentials[:secret_access_key])
        cloudwatch_logs = Aws::CloudWatchLogs::Client.new(credentials: aws_credentials)
        log_group_name = Activejob::Web.aws_credentials[:cloudwatch_log_group]
        request_data = { log_group_name:, log_stream_name: log_stream_name, limit: 10_000, start_from_head: false }
        request_data.merge!({ next_token: page_token }) if page_token.present?
        cloudwatch_logs.get_log_events(request_data)
      rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
        []
      end
    end
  end
end
