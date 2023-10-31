class ActivejobWeb::Job < ApplicationRecord
  self.primary_key = 'id'
  self.table_name = 'activejob_web_jobs'

  # Associations
  has_and_belongs_to_many :approvers, class_name: Activejob::Web.job_approvers_class.to_s, join_table: 'activejob_web_job_approvers'
  has_and_belongs_to_many :executors, class_name: Activejob::Web.job_executors_class.to_s, join_table: 'activejob_web_job_executors'

  # Validations
  validates :title, presence: true, length: { maximum: 255 } # Maximum 255 characters for title
  validates :description, presence: true, length: { maximum: 1000 } # Maximum 1000 characters for description
  # Default value for queue
  after_initialize :set_default_queue

  private

  # Default value for queue
  def set_default_queue
    self.queue ||= 1 # Set your desired default value for the queue attribute
  end
end
