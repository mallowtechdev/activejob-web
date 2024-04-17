# frozen_string_literal: true

module Activejob
  module Web
    class JobApprovalRequest < ApplicationRecord
      enum response: {
        rejected: 0,
        approved: 1,
        revoked: 2
      }

      # == Associations ==================================================================================================
      belongs_to :approver
      belongs_to :job_execution
    end
  end
end
