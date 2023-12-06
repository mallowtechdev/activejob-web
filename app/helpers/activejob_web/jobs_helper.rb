# frozen_string_literal: true

module ActivejobWeb
  module JobsHelper
    include AuthenticationHelper

    def activejob_web_current_user
      my_app_current_user
    end

    def activejob_web_login_path
      my_app_login_path
    end
  end
end
