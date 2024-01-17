# frozen_string_literal: true

module ActivejobWeb
  class Job < ApplicationRecord
    self.primary_key = 'id'

    enum queue: {
      default: 0,
      long_processing: 1
    }
    # == Validations ===================================================================================================
    validates :title, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 1000 }

    # == Callbacks =====================================================================================================
    after_initialize :set_default_queue
    has_one_attached :template_file

    private

    # Default value for queue
    def set_default_queue
      self.queue ||= 'default' # Set your desired default value for the queue attribute
    end
  end
end
