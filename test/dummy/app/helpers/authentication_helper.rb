# frozen_string_literal: true

module AuthenticationHelper
  def my_app_current_user
    # Specify the current user here
    current_user
  end

  def my_app_login_path
    # Specify the path to redirect when user not authenticated
    user_login_path
  end
end
