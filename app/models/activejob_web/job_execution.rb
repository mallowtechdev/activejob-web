class ActivejobWeb::JobExecution < ApplicationRecord
  enum status: {
    requested: 0,
    approved: 1,
    rejected: 2,
    executed: 3,
    cancelled: 4,
    succeeded: 5,
    failed: 6
  }

  validates :requestor_comments, presence: true

  after_initialize :set_default_status
  belongs_to :activejob_web_job, :class_name => 'ActivejobWeb::Job'

  private

  def set_default_status
    self.status ||= :requested
  end
end
