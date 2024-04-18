# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :activejob_web_jobs, id: false do |t|
      t.uuid :id, default: -> { 'gen_random_uuid()' }, null: false
      t.string :title
      t.string :description
      t.json :input_arguments
      t.integer :max_run_time
      t.integer :minimum_approvals_required
      t.integer :priority
      t.integer :queue
      t.string :job_name

      t.timestamps
    end
  end
end
