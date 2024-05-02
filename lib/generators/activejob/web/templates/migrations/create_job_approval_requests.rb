# frozen_string_literal: true

class CreateJobApprovalRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :activejob_web_job_approval_requests do |t|
      t.integer :job_execution_id
      t.integer :approver_id
      t.integer :response
      t.string :approver_comments

      t.timestamps
    end
  end
end
