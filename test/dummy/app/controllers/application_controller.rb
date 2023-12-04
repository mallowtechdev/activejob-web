# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActivejobWeb::JobsHelper
  before_action :authenticate_user_new!
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def authenticate_user_new!
    return if session[:authentication_checked]

    return unless job_current_user.nil?

    session[:authentication_checked] = true
    redirect_to job_login_path, alert: 'Please log in'
  end
end
