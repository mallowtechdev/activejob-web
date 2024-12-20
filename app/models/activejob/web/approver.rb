# frozen_string_literal: true

module Activejob
  module Web
    class Approver < Activejob::Web.approvers_model.constantize
      include Activejob::Web::UsersConcern

      has_and_belongs_to_many :jobs, class_name: 'Activejob::Web::Job', join_table: 'activejob_web_job_approvers'
      has_many :job_approval_requests
    end
  end
end
