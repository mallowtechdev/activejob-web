# frozen_string_literal: true

module UserHelper
  def my_app_current_user
    # Specify the current user here
    User.find(1)
  end

  def my_app_login_path
    # Specify the path to redirect when user not authenticated
    root_path
  end
end
