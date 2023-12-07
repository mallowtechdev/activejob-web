# frozen_string_literal: true

module AuthenticationHelper
  def my_app_current_user
    # Specify the current user here
    User.first
  end
end
