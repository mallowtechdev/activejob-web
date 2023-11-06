# frozen_string_literal: true

module ActivejobWeb
  class Job < ApplicationRecord
    self.primary_key = 'id'

    # == Associations ==================================================================================================
    has_and_belongs_to_many :approvers, class_name: Activejob::Web.job_approvers_class.to_s, join_table: 'activejob_web_job_approvers',
                                        association_foreign_key: 'approver_id'
    has_and_belongs_to_many :executors, class_name: Activejob::Web.job_executors_class.to_s, join_table: 'activejob_web_job_executors',
                                        association_foreign_key: 'executor_id'

    # == Validations ===================================================================================================
    validates :title, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 1000 }

    # == Callbacks =====================================================================================================
    after_initialize :set_default_queue

    private

    # Default value for queue
    def set_default_queue
      self.queue ||= 1 # Set your desired default value for the queue attribute
    end
  end
end
