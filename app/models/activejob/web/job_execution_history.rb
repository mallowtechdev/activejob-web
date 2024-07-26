# frozen_string_literal: true

module Activejob
  module Web
    class JobExecutionHistory < ApplicationRecord
      belongs_to :job
      belongs_to :job_execution

      has_one_attached :input_file

      validates :details, presence: true
      validates :arguments, presence: true
      validates :job, presence: true
      validates :job_execution, presence: true

      def current_history?
        is_current
      end

      def log_events(page_token = nil, opt = {})
        aws_credentials = Aws::Credentials.new(Activejob::Web.aws_credentials[:access_key_id], Activejob::Web.aws_credentials[:secret_access_key])
        cloudwatch_logs = Aws::CloudWatchLogs::Client.new(credentials: aws_credentials)
        log_group_name = Activejob::Web.aws_credentials[:cloudwatch_log_group]
        request_data = { log_group_name: log_group_name, log_stream_name: log_stream_name, limit: 10_000, start_from_head: false }
        request_data.merge!({ next_token: page_token }) if page_token.present?
        request_data.merge!(opt) if opt.present?
        cloudwatch_logs.get_log_events(request_data)
      rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
        []
      end
    end
  end
end
