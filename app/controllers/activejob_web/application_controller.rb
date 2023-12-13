# frozen_string_literal: true

module ActivejobWeb
  class ApplicationController < ActionController::Base
    include AuthenticationHelper
    helper_method :activejob_web_current_user
    before_action :activejob_web_authenticate_user
    protect_from_forgery with: :exception

    protected

    def activejob_web_authenticate_user
      return if session[:authentication_checked]

      return unless activejob_web_current_user.nil?

      session[:authentication_checked] = true
      redirect_to activejob_web_login_path, alert: 'Please log in'
    end
  end
end
