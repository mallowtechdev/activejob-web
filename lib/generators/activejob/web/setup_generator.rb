# frozen_string_literal: true

module Activejob
  module Web
    module Generators
      class SetupGenerator < Rails::Generators::Base
        include Rails::Generators::Migration
        source_root File.expand_path('templates', __dir__)

        def create_initializer_file
          template 'initializers/initializer.rb', 'config/initializers/activejob_web.rb'
        end

        def create_migration_files
          migration_template 'migrations/create_jobs.html.erb',
                             'db/migrate/create_jobs.rb'
          migration_template 'migrations/create_join_table_job_approvers.html.erb',
                             'db/migrate/create_join_table_job_approvers.rb'
          migration_template 'migrations/create_join_table_job_executors.html.erb',
                             'db/migrate/create_join_table_job_executors.rb'
          migration_template 'migrations/create_activejob_web_job_executions.html.erb',
                             'db/migrate/create_activejob_web_job_executions.rb'
          migration_template 'migrations/create_job_approval_requests.html.erb',
                             'db/migrate/create_job_approval_requests.rb'
          migration_template 'migrations/create_active_storage_tables.active_storage.html.erb',
                             'db/migrate/create_active_storage_tables.active_storage.rb'
          migration_template 'migrations/create_job_execution_histories.html.erb',
                             'db/migrate/create_job_execution_histories.rb'
        end

        def self.next_migration_number(dirname)
          next_migration_number = current_migration_number(dirname) + 1
          ActiveRecord::Migration.next_migration_number(next_migration_number)
        end
      end
    end
  end
end
