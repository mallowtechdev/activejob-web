module Activejob
  module Web
    class JobOne < ApplicationJob
      include Activejob::Web::JobConcern

      queue_as :default

      def perform(name, patter)
        activejob_web_logger.info 'JobOne performing...'
        activejob_web_logger.info "Name: #{name}, Patter: #{patter}"

        sleep 5
        activejob_web_logger.info "JobOne performed successfully."
      rescue StandardError => e
        activejob_web_logger.info "Error in JobOne: Error: #{e.inspect}"
        @rescued_exception = { message: e.message }
      end
    end
  end
end
