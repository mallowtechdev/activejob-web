# frozen_string_literal: true

module Activejob
  module Web
    module Configuration
      DEFAULT_CLASS = 'User'

      VALID_CONFIG_KEYS = {
        approvers_model: DEFAULT_CLASS,
        executors_model: DEFAULT_CLASS,
        admins_model: DEFAULT_CLASS,
        current_user_method: nil
      }.freeze

      PRIVATE_CONFIG_KEYS = {
        is_common_model: false,
        common_model: 'ApplicationRecord'
      }.freeze

      mattr_accessor(*VALID_CONFIG_KEYS.keys)
      mattr_accessor(*PRIVATE_CONFIG_KEYS.keys)

      def self.extended(base)
        base.setup
      end

      def configure
        yield self

        self.is_common_model = approvers_model == executors_model
        self.common_model = approvers_model if self.is_common_model
      end

      def options
        opts = {}
        VALID_CONFIG_KEYS.each_key do |k|
          opts.merge!(k => send(k))
        end
        opts
      end

      def setup
        VALID_CONFIG_KEYS.each do |k, v|
          send(:"#{k}=", v)
        end

        PRIVATE_CONFIG_KEYS.each do |k, v|
          send(:"#{k}=", v)
        end
      end

      def development?
        environment == 'development'
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
