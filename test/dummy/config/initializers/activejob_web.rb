# frozen_string_literal: true

Activejob::Web.configure do |config|
  config.approvers_model = 'User'
  config.executors_model = 'User'
  config.admins_model = 'User'
  config.current_user_method = :current_user
end
