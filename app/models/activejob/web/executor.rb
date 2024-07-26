# frozen_string_literal: true

module Activejob
  module Web
    class Executor < Activejob::Web.executors_model.constantize
      include Activejob::Web::UsersConcern

      has_and_belongs_to_many :jobs, class_name: 'Activejob::Web::Job', join_table: 'activejob_web_job_executors'
      has_many :job_executions, foreign_key: :requestor_id
    end
  end
end
