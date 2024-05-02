module Activejob
  module Web
    module Generators
      class SetupGenerator < Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        def create_initializer_file
          template 'initializers/initializer.rb', 'config/initializers/activejob_web.rb'
        end

        def create_migration_files
          template 'migrations/create_jobs.rb', "db/migrate/#{generated_time_stamp}_create_jobs.rb"
          template 'migrations/create_join_table_job_approvers.rb', "db/migrate/#{generated_time_stamp}_create_join_table_job_approvers.rb"
          template 'migrations/create_join_table_job_executors.rb', "db/migrate/#{generated_time_stamp}_create_join_table_job_executors.rb"
          template 'migrations/create_activejob_web_job_executions.rb', "db/migrate/#{generated_time_stamp}_create_activejob_web_job_executions.rb"
          template 'migrations/create_job_approval_requests.rb', "db/migrate/#{generated_time_stamp}_create_job_approval_requests.rb"
        end

        private

        def generated_time_stamp
          sleep 1.5
          Time.now.utc.strftime('%Y%m%d%H%M%S')
        end
      end
    end
  end
end
