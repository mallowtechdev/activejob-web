# frozen_string_literal: true

class User < ApplicationRecord

  alias_attribute :name, :email
  # == Associations ==================================================================================================
  has_many :job_approval_requests

  # == Validations ===================================================================================================
  validates :name, presence: true, length: { maximum: 50 }

  # == Scopes ========================================================================================================
  scope :active_job_admins, -> { User.all }
end
