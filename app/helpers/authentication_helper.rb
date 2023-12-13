# frozen_string_literal: true

module AuthenticationHelper
  def activejob_web_current_user
    # Specify the current user here
    User.first
  end

  def activejob_web_login_path
    # Specify the path to redirect when user not authenticated
    login_path
  end
end
