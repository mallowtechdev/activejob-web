class CreateActivejobWebJobExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :activejob_web_job_executions ,id: :uuid do |t|
      t.integer :requestor_id
      t.references :activejob_web_jobs,type: :uuid, null: false, foreign_key: true
      t.string :requestor_comments
      t.json :arguments
      t.integer :status
      t.string :reason_for_failure
      t.boolean :auto_execute_on_approval
      t.timestamp :run_at
      t.timestamp :execution_started_at
      t.timestamps
    end
  end
end
