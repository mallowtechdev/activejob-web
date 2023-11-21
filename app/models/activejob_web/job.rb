class ActivejobWeb::Job < ApplicationRecord
  self.primary_key = 'id'
  # Validations
  validates :title, presence: true, length: { maximum: 255 } # Maximum 255 characters for title
  validates :description, presence: true, length: { maximum: 1000 } # Maximum 1000 characters for description
  # The input_arguments is optional, so no validation needed
  # Default value for queue
  after_initialize :set_default_queue
  has_one_attached :template_file
  has_many :activejob_web_job_executions, :class_name => 'ActivejobWeb::JobExecution'
  private
  # Default value for queue
  def set_default_queue
    self.queue ||= 'default' # Set your desired default value for the queue attribute
  end
end

