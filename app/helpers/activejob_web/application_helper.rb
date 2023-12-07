# frozen_string_literal: true

module ActivejobWeb
  module ApplicationHelper
    include AuthenticationHelper

    def activejob_web_current_user
      my_app_current_user
    end
  end
end
