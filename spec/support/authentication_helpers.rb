# frozen_string_literal: true

module AuthenticationHelpers
  include ActivejobWeb::JobsHelper
  def sign_in_user(user)
    post job_login_path, params: { email: user.email, password: 'password' }
  end
end
