# frozen_string_literal: true

module Activejob
  module Web
    class ApplicationController < ApplicationController
      layout 'activejob/web/layouts/application'

      include ActiveStorage::SetCurrent
      include Activejob::Web::Authentication
      before_action :authorized?
      protect_from_forgery with: :exception

      private

      def authorized?
        redirect_to root_path, alert: 'You are not authorized to perform this action' unless Activejob::Web::Authorization.authorized?(
          @activejob_web_current_user,
          controller_name,
          action_name
        )
      end
    end
  end
end
