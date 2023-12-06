# frozen_string_literal: true

class User < ApplicationRecord
  extend ActivejobWeb::JobsHelper
  # == Associations ==================================================================================================
  has_and_belongs_to_many :executors, class_name: ActivejobWeb::Job.to_s, join_table: 'activejob_web_job_executors',
                                      association_foreign_key: 'executor_id'

  # == Validations ===================================================================================================
  validates :name, presence: true, length: { maximum: 50 }

  # == Scopes ========================================================================================================
  scope :super_admin_users, -> { User.all }

  def self.allow_admin_access?
    lambda do |_request|
      super_admin_users.include?(activejob_web_current_user)
    end
  end
end
