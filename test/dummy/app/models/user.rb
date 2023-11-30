# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # == Associations ==================================================================================================
  has_and_belongs_to_many :executors, class_name: 'ActivejobWeb::Job', join_table: 'activejob_web_job_executors',
                                      association_foreign_key: 'executor_id'
  has_many :job_approval_requests

  # == Validations ===================================================================================================
  validates :name, presence: true, length: { maximum: 50 }

  # == Scopes ========================================================================================================
  scope :super_admin_user, -> { User.all }

  def self.custom_lambda
    lambda do |request|
      current_user = request.env['warden'].user
      super_admin_user.include?(current_user)
    end
  end
end