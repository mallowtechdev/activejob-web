# frozen_string_literal: true

module ActivejobWeb
  class ApplicationController < ActionController::Base
    include ActivejobWeb::ApplicationHelper
    protect_from_forgery with: :exception
  end
end
