# frozen_string_literal: true

User.create(
  name: 'Admin',
  email: 'activejob_web_admin@example.com',
  password: 'password123',
  is_admin: true
)

approver = User.create(
  name: 'Approver',
  email: 'activejob_web_approver@example.com',
  password: 'password123',
  is_admin: false
)

executor = User.create(
  name: 'Executor',
  email: 'activejob_web_executor@example.com',
  password: 'password123',
  is_admin: false
)

job_one = Activejob::Web::Job.new(
  title: "Job With String",
  description: "Active Job with String Inputs",
  input_arguments: [
    {
      name: 'name',
      type: 'String',
      required: true,
      "max_length": '10'
    },
    {
      "name": 'regex string',
      "type": 'String',
      "required": true,
      "allowed_characters": { 'regex' => /\A\d+\z/, 'description' => 'Regex String' },
    }
  ],
  max_run_time: 60,
  minimum_approvals_required: 0,
  priority: 1,
  job_name: 'JobOne'
)

job_one.executor_ids = [executor.id]
if job_one.save
  puts "Job With String has been created successfully."
  #==== specified the file path and used File.open method to get the file, then attached the file
  file_path = 'app/assets/images/activejob/web/lorem_ipsum.jpg'
  file = File.open(file_path, 'rb')
  job_one.template_file.attach(io: file, filename: 'lorem_ipsum.jpg')
else
  puts "Error in creating Job With String: #{job_one.errors.full_messages.join(', ')}"
end

job_two = Activejob::Web::Job.new(
  title: "Job With File",
  description: "Active Job with File Input",
  input_arguments: [
    {
      "name": 'file',
      "type": 'File',
      "required": true
    }
  ],
  max_run_time: 60,
  minimum_approvals_required: 1,
  priority: 1,
  job_name: 'JobTwo'
)
job_two.approver_ids = [approver.id]
job_two.executor_ids = [executor.id]
if job_two.save
  puts "Job With File has been created successfully."
else
  puts "Error in creating Job With File: #{job_two.errors.full_messages.join(', ')}"
end