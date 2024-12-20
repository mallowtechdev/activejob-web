# frozen_string_literal: true

module Activejob
  module Web
    module JobApprovalRequestsHelper
      def job_approval_response_keys
        Activejob::Web::JobApprovalRequest.responses.keys
      end
    end
  end
end
