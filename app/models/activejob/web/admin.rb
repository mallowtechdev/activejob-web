# frozen_string_literal: true

module Activejob
  module Web
    class Admin < Activejob::Web.admins_model.constantize
      include Activejob::Web::UsersConcern

      def jobs
        Activejob::Web::Job.all
      end

      def job_approval_requests
        Activejob::Web::JobApprovalRequest.all
      end
    end
  end
end
