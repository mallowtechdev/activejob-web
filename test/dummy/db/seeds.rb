10.times do |i|
  job = ActivejobWebJob.new(
    title: "Job Title #{i + 1}",
    description: "Job Description #{i + 1}",
    input_arguments: [
      {
        "name": "File",
        "type": "File",
        "allowed_characters": "<Regexp>",
        "max_length": "10",
        "required": true
      },
      {
        "name": "Imported Date",
        "type": "Date",
        "required": true
      },
      {
        "name": "Imported Date and Time",
        "type": "DateTime",
        "required": true
      },
      {
        "name": "client name",
        "type": "String",
        "required": true,
        "allowed_characters": "<Regexp>",
        "max_length": "10"
      },
      {
        "name": "Booking ID",
        "type": "integer"
      }
    ],
    max_run_time: 60,
    minimum_approvals_required: 2,
    priority: 1
  )

  if job.save
    puts "Job #{i + 1} has been created successfully."
  else
    puts "Error creating Job #{i + 1}: #{job.errors.full_messages.join(', ')}"
  end
end
#==== specified the file path and used File.open method to get the file, then attached the file
file_path = "app/assets/images/activejob/web/sample.png"
file = File.open(file_path, 'rb')
ActivejobWebJob.first.template_file.attach(io: file, filename: 'sample.png')
