class CreateActivejobWebJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :activejob_web_jobs do |t|
      t.string :title
      t.string :description
      t.json :input_arguments
      t.integer :max_run_time
      t.integer :minimum_approvals_required
      t.integer :priority
      t.string :queue
      t.timestamps
    end
  end
end
