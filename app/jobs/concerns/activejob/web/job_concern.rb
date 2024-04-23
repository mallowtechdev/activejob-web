module Activejob
  module Web
    module JobConcern
      extend ActiveSupport::Concern

      included do
        queue_as :default

        attr_accessor :rescued_exception

        before_perform do |job|
          job.rescued_exception = {}
        end

        after_perform :update_job_executions

        def update_job_executions
          Activejob::Web::JobExecution.update_job_execution_status(self)
        end
      end
    end
  end
end