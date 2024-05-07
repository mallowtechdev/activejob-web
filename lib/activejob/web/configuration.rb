# frozen_string_literal: true

module Activejob
  module Web
    module Configuration
      DEFAULT_CLASS = 'User'

      VALID_CONFIG_KEYS = {
        approvers_model: DEFAULT_CLASS,
        executors_model: DEFAULT_CLASS,
        admins_model: DEFAULT_CLASS,
        current_user_method: nil,
        aws_credentials: {}
      }.freeze

      PRIVATE_CONFIG_KEYS = {
        is_common_model: false,
        common_model: 'ApplicationRecord'
      }.freeze

      mattr_accessor(*VALID_CONFIG_KEYS.keys)
      mattr_accessor(*PRIVATE_CONFIG_KEYS.keys)

      def self.extended(base)
        base.initial_setup
      end

      def configure
        yield self

        common_model_setup
      end

      def common_model_setup
        self.is_common_model = approvers_model == executors_model
        self.common_model = approvers_model if is_common_model

        validate!
      end

      def validate!
        validate_config!
        valid_aws_credentials? if aws_credentials_present?
      end

      def validate_config!
        VALID_CONFIG_KEYS.each_key do |key|
          case key
          when :approvers_model, :executors_model, :admins_model
            raise "TypeError: #{key} Name should be a String" unless send(key).is_a?(String)
          when :aws_credentials
            raise "TypeError: #{key} should be a Hash" unless send(key).is_a?(Hash)
          end
        end
      end

      def options
        opts = {}
        VALID_CONFIG_KEYS.each_key do |k|
          opts.merge!(k => send(k))
        end
        opts
      end

      def initial_setup
        VALID_CONFIG_KEYS.each do |k, v|
          send(:"#{k}=", v)
        end

        PRIVATE_CONFIG_KEYS.each do |k, v|
          send(:"#{k}=", v)
        end

        common_model_setup
      end

      def development?
        environment == 'development'
      end

      def aws_credentials_present?
        aws_credentials.present? && aws_credentials[:access_key_id].present? &&
          aws_credentials[:secret_access_key].present? && aws_credentials[:cloudwatch_log_group].present?
      end

      def valid_aws_credentials?
        credentials = Aws::Credentials.new(aws_credentials[:access_key_id], aws_credentials[:secret_access_key])
        cloudwatch_logs = Aws::CloudWatchLogs::Client.new(credentials:)
        cloudwatch_logs.describe_log_streams(log_group_name: aws_credentials[:cloudwatch_log_group])
      rescue  Aws::CloudWatchLogs::Errors::UnrecognizedClientException
        raise 'UnrecognizedClientException - Invalid AWS Credentials'
      rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
        raise 'ResourceNotFoundException - Invalid CloudWatch Log Group Name'
      end

      private

      def environment
        if defined?(::Rails)
          ::Rails.env.to_s
        else
          ENV.fetch('RACK_ENV') { ENV.fetch('RAILS_ENV', 'development') }.to_s
        end
      end
    end
  end
end
