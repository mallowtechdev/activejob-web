# frozen_string_literal: true

class CreateJoinTableJobApprovers < ActiveRecord::Migration[7.0]
  def change
    create_table :activejob_web_job_approvers, id: false do |t|
      t.column :job_id, :uuid
      t.column :approver_id, :integer
    end
  end
end
