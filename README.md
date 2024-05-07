# Activejob::Web
`Activejob::Web` is a Rails engine, which means it's a packaged set of functionality that can be easily integrated into a Ruby on Rails application. This engine specifically focuses on providing a web-based dashboard. This dashboard serves the purpose of managing and monitoring background job processing within a Ruby on Rails application


## Usage
The `ActiveJob::Web` engine simplifies the execution of active jobs by providing a user-friendly interface accessible through a web browser.


## Getting Started

## Gem Installation
Add this line to your application's Gemfile:

```ruby
gem "activejob-web"
```

And then execute:
```bash
$ bundle install
```

## Setup
you need to run the generator:
```bash
$ rails generate activejob:web:setup
```

The generator adds these core files, among others:

- `activejob_web.rb`: Initializer file in the `config/initializers` directory.
- Migrations in the `db/migrate` directory:

    - `create_jobs.rb`
    - `create_activejob_web_job_executions.rb`
    - `create_join_table_job_executors.rb`
    - `create_job_approval_requests.rb`
    - `create_join_table_job_approvers.rb`
    - `create_active_storage_tables.active_storage.rb`

Then run:
```bash
$ rake db:migrate
```

## Create Activejob Web Jobs
ActiveJob Web jobs should be created from the backend. Use ActiveJob::Web::Job to create the jobs

```ruby
  job = Activejob::Web::Job.new(
  title: "Sample Title",
  description: "Sample Description",
  input_arguments: [
      ...
    {
      "name": "sample name",
      "type": "String",
      "required": true,
      "allowed_characters": "<Regexp>",
      "max_length": "10"
    },
    {
      "name": "file",
      "type": "File",
      "required": true
    } 
      ...
  ],
  max_run_time: 60,
  minimum_approvals_required: 2,
  priority: 1,
  job_name: '<JOB_NAME>' # SampleJob
)

job.save

#==== specified the file path and used File.open method to get the file, then attached the file
file_path = "/../sample.png"
file = File.open(file_path, 'rb')
job.template_file.attach(io: file, filename: 'sample.png')
```

Or

Run the following command in the terminal:

```bash
# [:title :description :max_run_time :minimum_approvals_required :priority :job_name]
# Input Arguments should be in the format '[{"key":"value","key":"value"}, { ... }]' Sample: '[{"name":"app_id","type":"Integer","required":true}]'
$ rake activejob:web:create_job['sample title','sample description',60,0,1,'SampleJob'] input_arguments='sample arguments'
```


## Configuring Activejob Web Approvers and Executors

By default, Activejob Web uses the `User` class as the model for job admins, approvers and executors. If you need to customize these classes, you can do so in the initializer file located at `config/initializers/activejob_web.rb`.

For example, if your models to configure are 'Author' and 'User', you can set the job approvers and executors classes as follows

```ruby
# config/initializers/activejob_web.rb

Activejob::Web.configure do |config|
  config.admins_model = 'User'
  config.approvers_model = 'User'
  config.executors_model = 'Author'
end
```
where, `admins_model`, `approvers_model` and `executors_model` were defined as `mattr_accessors` in Activejob Web gem.

## Configuration for Authentication
The ActivejobWeb Gem integrates with the authentication system used in your Rails application. To set up authentication,

### Option One
Specify the `current_user_method` in `config/initializers/activejob_web.rb` as shown below

```ruby
# config/initializers/activejob_web.rb

Activejob::Web.configure do |config|
  ...
  config.current_user_method = :current_user
  ...
end
```

Specify the `current_user` helper method in the `apps/helpers/application_helper.rb` file

```ruby
# app/helpers/application_helper.rb

module ApplicationHelper
  def current_user
    # Specify the current user here
  end
end
```

### Option Two
Specify the `activejob_web_user` helper method in the `apps/helpers/application_helper.rb` file

```ruby
# app/helpers/application_helper.rb

module ApplicationHelper
  def activejob_web_user
    # Specify the current user here
    current_user
  end
end
```

Make sure that your application configured the `current_user` method.

## Active Job Configuration
Include `ActiveJob::Web::JobConcern` in the Active Job you want to execute from the browser. Assign the error message to `@rescued_exception` to keep track of job failures.

```ruby
# app/jobs/job_one.rb

class JobOne < ActiveJob::Base
  include Activejob::Web::JobConcern

  def perform
    # code...
  rescue StandardError => e
    Rails.logger.info "Error: #{e.message}"
    @rescued_exception = { message: e.message }
  end
end
```


## CloudWatch Configuration
By default, ActiveJob::Web uses the default Rails.logger for logging. It creates separate logs for each execution. If you need to configure CloudWatch, you can do so in the initializer.

```ruby
# config/initializers/activejob_web.rb

Activejob::Web.configure do |config|
  ...
  config.aws_credentials = {
    access_key_id: '<ACCESS_KEY_ID>',
    secret_access_key: '<SECRET_ACCESS_KEY>',
    cloudwatch_log_group: '<LOG_GROUP_NAME>'
  }
  ...
end
```
CloudWatch Log Stream name will be constructed as following
```ruby
"#{job_execution_id}_#{job_id}" # 1_865403ac-5ac3-43da-b291-d65be727a892
```

### Streaming logs to CloudWatch
Use the `activejob_web_logger` Logger to stream the logs to CloudWatch.

```ruby
# app/jobs/job_one.rb

class JobOne < ActiveJob::Base
  include Activejob::Web::JobConcern

  def perform
    # code...
  rescue StandardError => e
    Rails.logger.info "Error: #{e.message}" # This log will be handled as the default.
    activejob_web_logger.info "Error: #{e.message}" # This log will be streamed to CloudWatch.
    @rescued_exception = { message: e.message }
  end
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
