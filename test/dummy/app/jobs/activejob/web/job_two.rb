# frozen_string_literal: true
module Activejob
  module Web
    class JobTwo < ApplicationJob
      include Activejob::Web::JobConcern

      queue_as :default

      def perform
        activejob_web_logger.info 'Performing JobTwo...'
        5.times do |i|
          activejob_web_logger.info "Loop Count: #{i}"
          sleep 1
        end
        raise 'CloudWatch: Raised Exception - Testing Error...'
      rescue StandardError => e
        activejob_web_logger.info "Error in JobTwo: Error: #{e.message}"
        @rescued_exception = { message: e.message }
      end
    end
  end
end
