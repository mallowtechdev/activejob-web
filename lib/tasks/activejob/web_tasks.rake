# frozen_string_literal: true

namespace :activejob do
  namespace :web do
    desc 'Create Activejob Web Job'
    task :create_job,
         %i[title description max_run_time minimum_approvals_required priority job_name] => :environment do |_task, args|
      Rake::Task['activejob:web:rake_log'].execute('Started creating Activejob Web Job task.')
      input_arguments = ENV.fetch('input_arguments')
      job_attributes = { title: ENV.fetch('title', args[:title]),
                         description: ENV.fetch('description', args[:description]),
                         input_arguments: input_arguments.present? ? JSON.parse(input_arguments) : nil,
                         max_run_time: ENV.fetch('max_run_time', args[:max_run_time]),
                         minimum_approvals_required: ENV.fetch('minimum_approvals_required',
                                                               args[:minimum_approvals_required]),
                         priority: ENV.fetch('priority', args[:priority]),
                         job_name: ENV.fetch('job_name', args[:job_name]) }

      begin
        Rake::Task['activejob:web:rake_log'].execute("Given Args: #{job_attributes}")
        Activejob::Web::Job.create!(job_attributes)
        Rake::Task['activejob:web:rake_log'].execute('Activejob Web Job created successfully.')
      rescue ActiveRecord::RecordInvalid => e
        Rake::Task['activejob:web:rake_log'].execute("Failed To Create Job: #{e.message}")
      end
    end

    private

    desc 'Logging activejob web task info'
    task :rake_log, [:message] => :environment do |_task, message|
      Rails.logger.info(message)
      puts(message)
    end
  end
end
