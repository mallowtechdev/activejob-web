# spec/support/shared_contexts.rb

# frozen_string_literal: true

RSpec.shared_context 'common setup', shared_context: :metadata do
  before do
    default_config
  end

  after do
    default_config
  end

  def default_config
    Activejob::Web.configure do |config|
      config.approvers_model = 'User'
      config.executors_model = 'User'
      config.admins_model = 'User'
    end
    Activejob::Web.is_common_model = true
    Activejob::Web.common_model = 'User'
  end

  def approver_config
    Activejob::Web.executors_model = 'Author'
    Activejob::Web.is_common_model = false
    Activejob::Web.common_model = 'ApplicationRecord'
  end

  def executor_config
    Activejob::Web.approvers_model = 'Author'
    Activejob::Web.is_common_model = false
    Activejob::Web.common_model = 'ApplicationRecord'
  end
end
