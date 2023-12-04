module UserHelper
  def testing_help
    p 'gowtham'
    'gowtham'
  end

  def my_app_current_user
    # Specify the current user here
    current_user
  end

  def my_app_login_path
    user_session_path
  end
end
