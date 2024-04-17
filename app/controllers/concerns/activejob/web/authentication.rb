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
        return false unless @activejob_web_current_user.present?

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
        # converted_model = if admin?
        #                     Activejob::Web::Admin.find(host_user_id)
        #                   elsif Activejob::Web.is_common_model
        #                     Activejob::Web::Common.find(host_user_id)
        #                   else
        #                     Activejob::Web::Approver.find_by(id: host_user_id)
        #                   end

        converted_model = Activejob::Web::Common.find(host_user_id)
        converted_model.present? ? converted_model : Activejob::Web::Executor.find(host_user_id)
      end

      def validate_current_user_helper
        return if helpers.respond_to?(current_user_helper)

        redirect_to login_path, alert: t('current_user_helper.method_missing')
      end
    end
  end
end