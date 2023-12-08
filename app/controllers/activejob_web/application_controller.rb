# frozen_string_literal: true

module ActivejobWeb
  class ApplicationController < ActionController::Base
    include ActivejobWeb::JobsHelper
    helper_method :activejob_web_current_user
    protect_from_forgery with: :exception
  end
end
