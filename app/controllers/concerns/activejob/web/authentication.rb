# frozen_string_literal: true

module Activejob
  module Web
    module Authentication
      extend ActiveSupport::Concern

      included do
        before_action :validate_current_user_helper
        before_action :activejob_web_current_user
        helper_method :activejob_web_current_user
        helper_method :user_signed_in?
        helper_method :admin?
      end

      # Need to check the model is converted or not
      def activejob_web_current_user
        host_user = fetch_host_user
        redirect_to login_path, alert: t('user.invalid') unless host_user

        @activejob_web_current_user = convert_user_model
      end

      def user_signed_in?
        activejob_web_current_user.present?
      end

      # Try to use the method instead of Instance
      def admin?
        return false unless @activejob_web_current_user.present? && validate_admin_model(@activejob_web_current_user)

        return true unless @activejob_web_current_user.respond_to?(:admin?)

        @activejob_web_current_user.admin?
      end

      private

      def current_user_helper
        Activejob::Web.current_user_method.presence || :activejob_web_current_user
      end

      def fetch_host_user
        @activejob_web_current_user ||= helpers.send(current_user_helper)
      end

      def convert_user_model
        host_user_id = @activejob_web_current_user.id
        if admin?
          Activejob::Web::Admin.find(host_user_id)
        elsif Activejob::Web.is_common_model
          Activejob::Web::Common.find(host_user_id)
        elsif valid_model?(@activejob_web_current_user, 'approvers')
          Activejob::Web::Approver.find(host_user_id)
        elsif valid_model?(@activejob_web_current_user, 'executors')
          Activejob::Web::Executor.find(host_user_id)
        end
      end

      def validate_current_user_helper
        return if helpers.respond_to?(current_user_helper)

        redirect_to login_path, alert: t('current_user_helper.method_missing')
      end

      def validate_admin_model(user)
        return true if user.respond_to?(:parsed_class_name) && user.parsed_class_name == 'Admin'

        user.class.name.to_s == Activejob::Web.admins_model
      end

      def valid_model?(user, model)
        user.class.name.to_s == Activejob::Web.public_send("#{model}_model")
      end
    end
  end
end
