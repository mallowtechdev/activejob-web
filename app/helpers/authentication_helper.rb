# frozen_string_literal: true

module AuthenticationHelper
  def activejob_web_current_user
    # Specify the current user here
    current_user
  end

  def activejob_web_login_path
    # Specify the path to redirect when user not authenticated
    root_path
  end
end
