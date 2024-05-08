module Activejob
  module Web
    class JobExecutionHistory < ApplicationRecord
      belongs_to :job
      belongs_to :job_execution
    end
  end
end
