# frozen_string_literal: true

module ActivejobWeb
  module JobsHelper
    include UserHelper

    def job_current_user
      my_app_current_user
    end

    def job_login_path
      my_app_login_path
    end
  end
end
