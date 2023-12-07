# frozen_string_literal: true

module ActivejobWeb
  class JobApprovalRequestsController < ApplicationController
    before_action :set_approval_request, only: %i[action update]

    def index
      @job_approval_requests = ActivejobWeb::JobApprovalRequest.where(job_execution_id: params[:job_execution_id],
                                                                      approver_id: activejob_web_current_user.id).includes(job_execution: %i[job user])
    end

    def action; end

    def update
      if params[:activejob_web_job_approval_request][:response].present? && @job_approval_request.update(job_approval_request_params)
        redirect_to activejob_web_job_job_execution_job_approval_requests_path(@job_approval_request),
                  notice: 'Job approval request updated successfully.'
      else
        redirect_to action_activejob_web_job_job_execution_job_approval_request_path(@job_approval_request),
                    notice: 'Please select either Approve or Decline to update.'
      end
    end

    private

    def set_approval_request
      @job_approval_request = ActivejobWeb::JobApprovalRequest.find(params[:id])
    end

    def job_approval_request_params
      params.require(:activejob_web_job_approval_request).permit(:response, :approver_comments)
    end
  end
end
