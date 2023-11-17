# frozen_string_literal: true

class CreateJoinTableJobExecutors < ActiveRecord::Migration[7.1]
  def change
    create_table :activejob_web_job_executors, id: false do |t|
      t.column :job_id, :uuid
      t.column :executor_id, :integer
    end
  end
end
