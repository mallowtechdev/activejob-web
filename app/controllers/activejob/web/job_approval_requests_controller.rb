# frozen_string_literal: true

module Activejob
  module Web
    class JobApprovalRequestsController < ApplicationController
      before_action :set_job, only: %i[index show update]
      before_action :user_authorized?
      before_action :set_approval_request, only: %i[show update]
      before_action :set_job_execution, only: %i[show update]

      def index
        @job_approval_requests = Activejob::Web::JobApprovalRequest
                                 .includes(:job_execution)
                                 .where(job_execution_id: @job.job_execution_ids,
                                        approver_id: @activejob_web_current_user.id)
      end

      def show; end

      def update
        if @job_approval_request.update(job_approval_request_params)
          flash[:notice] = 'Job approval request updated successfully.'
        else
          flash[:alert] = 'Please select either Approve or Decline to update.'
        end
        redirect_to activejob_web_job_job_approval_requests_path(@job)
      end

      private

      def set_job
        @job = Activejob::Web::Job.find(params[:job_id])
      end

      def set_approval_request
        @job_approval_request = @activejob_web_current_user.job_approval_requests.includes(:job_execution).find(params[:id])
      end

      def set_job_execution
        @job_execution = @job_approval_request.job_execution
      end

      def job_approval_request_params
        params.require(:activejob_web_job_approval_request).permit(:response, :approver_comments)
      end

      def user_authorized?
        redirect_to root_path, alert: t('action.not_authorized') unless admin? || @job.approver_ids.include?(@activejob_web_current_user.id)
      end
    end
  end
end
