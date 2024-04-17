module Activejob
  module Web
    class Common < Activejob::Web.common_model.constantize
      include Activejob::Web::UsersConcern

      has_and_belongs_to_many :approver_jobs,
                              class_name: 'Activejob::Web::Job',
                              join_table: 'activejob_web_job_approvers',
                              foreign_key: :approver_id
      has_and_belongs_to_many :executor_jobs,
                              class_name: 'Activejob::Web::Job',
                              join_table: 'activejob_web_job_executors',
                              foreign_key: :executor_id


      has_many :job_approval_requests, foreign_key: :approver_id

      def jobs
        Activejob::Web::Job.where(id: (approver_job_ids + executor_job_ids).uniq)
      end
    end
  end
end