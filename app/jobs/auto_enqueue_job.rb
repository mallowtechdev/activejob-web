class AutoEnqueueJob < ApplicationJob
  queue_as :default

  def perform(job_id,input_arguments)
    #  puts "Processing AutoEnqueueJob for JobExecution ID: #{job_execution_id}, Job ID: #{job_id}, Input Arguments: #{input_arguments}"
  end
end
