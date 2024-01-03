# frozen_string_literal: true

class User < ApplicationRecord
  extend AuthenticationHelper

  # == Validations ===================================================================================================
  validates :name, presence: true, length: { maximum: 50 }

  # == Scopes ========================================================================================================
  scope :active_job_admins, -> { User.all }

  def self.allow_admin_access?
    lambda do |_request|
      active_job_admins.include?(activejob_web_current_user)
    end
  end
end
