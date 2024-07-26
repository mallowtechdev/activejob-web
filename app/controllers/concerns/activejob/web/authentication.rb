# frozen_string_literal: true

module Activejob
  module Web
    module Authentication
      extend ActiveSupport::Concern

      included do
        before_action :validate_current_user_helper
        before_action :set_activejob_web_current_user
        helper_method :activejob_web_current_user, :user_signed_in?, :admin?
      end

      def activejob_web_current_user
        @activejob_web_current_user ||= convert_user_model(fetch_host_user)
      end

      def user_signed_in?
        activejob_web_current_user.present?
      end

      def admin?(user = activejob_web_current_user)
        @admin ||= user_admin?(user)
      end

      private

      def validate_current_user_helper
        return if helpers.respond_to?(current_user_helper)

        redirect_to root_path,
                    alert: "Please configure the 'current_user_method' in the ActiveJob::Web configuration, " \
                           "or add the helper method 'activejob_web_user' to the ApplicationHelper."
      end

      def set_activejob_web_current_user
        return user_invalid_redirect if fetch_host_user.blank?

        @activejob_web_current_user = convert_user_model(fetch_host_user)
      end

      def fetch_host_user
        helpers.send(current_user_helper)
      end

      def convert_user_model(user)
        if admin?(user)
          Activejob::Web::Admin.find(user.id)
        elsif Activejob::Web.is_common_model
          Activejob::Web::Common.find(user.id)
        elsif valid_model?(user, 'approvers')
          Activejob::Web::Approver.find(user.id)
        elsif valid_model?(user, 'executors')
          Activejob::Web::Executor.find(user.id)
        end
      end

      def user_admin?(user)
        return false unless user.present? && validate_admin_model(user)

        return true unless user.respond_to?(:admin?)

        user.admin?
      end

      def validate_admin_model(user)
        return true if user.respond_to?(:parsed_class_name) && user.parsed_class_name == 'Admin'

        user.class.name.to_s == Activejob::Web.admins_model
      end

      def current_user_helper
        Activejob::Web.current_user_method.presence || :activejob_web_user
      end

      def valid_model?(user, model)
        user.class.name.to_s == Activejob::Web.public_send("#{model}_model")
      end

      def user_invalid_redirect
        redirect_to root_path, alert: 'User not found or invalid.'
      end
    end
  end
end
