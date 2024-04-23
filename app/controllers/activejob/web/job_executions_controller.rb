# frozen_string_literal: true

module Activejob
  module Web
    class JobExecutionsController < ApplicationController
      before_action :set_job
      before_action :user_authorized?
      before_action :set_job_execution, only: %i[show edit update cancel reinitiate execute]
      before_action :validate_status, only: %i[edit]

      def index
        @job_executions = @job.job_executions.where(requestor_id: @activejob_web_current_user.id)
        @job_execution = Activejob::Web::JobExecution.new(job_id: @job.id)
      end

      def show
        @job_execution = @job.job_executions.find(params[:id])
        @job_approval_requests = @job_execution.job_approval_requests
      end

      def edit; end

      def update
        @job_execution.arguments = params['arguments']
        if @job_execution.update(job_execution_params)
          redirect_to activejob_web_job_job_execution_path(@job), notice: 'Job execution was successfully updated.'
        else
          render :show
        end
      end

      def create
        @job_execution = @job.job_executions.new(job_execution_params)
        @job_execution.arguments = params['arguments']
        @job_execution.requestor_id = @activejob_web_current_user.id if @job_execution.requestor_id.nil?
        if @job_execution.save
          redirect_to activejob_web_job_job_executions_path(@job), notice: 'Job execution created successfully.'
        else
          render :index
        end
      end

      def cancel
        if @job_execution.cancel_execution && @job_execution.update(status: 'cancelled')
          flash[:notice] = 'Job execution cancelled successfully.'
        else
          flash[:alert] = 'Unable to cancel job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def reinitiate
        if @job_execution.cancelled?
          @job_execution.update(status: 'requested')
          @job_execution.revoke_approval_requests
          flash[:notice] = 'Job execution Reinitiated successfully.'
        else
          flash[:alert] = 'Unable to Reinitiate job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def execute
        if @job_execution.execute
          flash[:notice] = 'Job Execution executed successfully.'
        else
          flash[:alert] = 'Failed to execute Job Execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      private

      def job_execution_params
        params.require(:activejob_web_job_execution).permit(:requestor_id, :requestor_comments, :status, :job_id, :auto_execute_on_approval, :arguments, :input_file)
      end

      def set_job
        @job = @activejob_web_current_user.jobs.find(params[:job_id])
      end

      def set_job_execution
        @job_execution = @job.job_executions.find(params[:id])
      end

      def user_authorized?
        redirect_to root_path, alert: t('action.not_authorized') unless admin? || @job.executor_ids.include?(@activejob_web_current_user.id)
      end

      def validate_status
        # return if @job_execution.job_approval_requests.pluck(:response).blank?
        #
        # redirect_to activejob_web_job_job_executions_path(@job), alert: 'This job approval request has been processed. You cannot edit this!'
      end
    end
  end
end
