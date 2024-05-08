# frozen_string_literal: true

module Activejob
  module Web
    class JobExecutionsController < ApplicationController
      before_action :set_job
      before_action :user_authorized?
      before_action :set_job_execution, only: %i[show edit update cancel reinitiate execute logs history]
      before_action :set_job_execution_history, only: :logs

      def index
        @job_executions = @job.job_executions.where(admin? ? nil : { requestor_id: @activejob_web_current_user.id })
        @job_execution = Activejob::Web::JobExecution.new(job_id: @job.id)
      end

      def show
        @job_execution = @job.job_executions.find(params[:id])
        @execution_history_count = @job_execution.job_execution_histories.count
        @job_approval_requests = Activejob::Web::JobApprovalRequest.includes(:approver).where(job_execution_id: @job_execution.id)
      end

      def edit; end

      def update
        @job_execution.arguments = params['arguments']
        if update_with_source_params(job_execution_params.merge({ status: 'requested' }))
          redirect_to activejob_web_job_job_execution_path(@job), notice: 'Job execution was successfully updated.'
        else
          render :show
        end
      end

      def create
        @job_execution = @job.job_executions.new(job_execution_params)
        @job_execution.arguments = params['arguments']
        @job_execution.requestor_id = @activejob_web_current_user.id if !admin? && @job_execution.requestor_id.nil?
        if @job_execution.save
          redirect_to activejob_web_job_job_executions_path(@job), notice: 'Job execution was successfully created.'
        else
          render :index
        end
      end

      def cancel
        if @job_execution.cancel_execution && update_with_source_params({ status: 'cancelled' })
          flash[:notice] = 'Job execution was successfully cancelled.'
        else
          flash[:alert] = 'Failed to cancel job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def reinitiate
        if @job_execution.cancelled? && update_with_source_params({ status: 'requested' })
          flash[:notice] = 'Job execution was successfully reinitiated.'
        else
          flash[:alert] = 'Failed to reinitiate job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def execute
        if @job_execution.execute
          flash[:notice] = 'Job execution was successfully executed.'
        else
          flash[:alert] = 'Failed to execute job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def history
        @job_execution_histories = @job_execution.job_execution_histories
      end

      def logs; end

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

      def set_job_execution_history
        @job_execution_history = @job_execution.job_execution_histories.find_by(id: params['history_id'])
      end

      def user_authorized?
        redirect_to root_path, alert: 'You are not authorized to perform this action' unless admin? || @job.executor_ids.include?(@activejob_web_current_user.id)
      end

      def update_with_source_params(source_params)
        source_params.merge!({ execution_started_at: nil, run_at: nil, reason_for_failure: nil })

        @job_execution.update(source_params) && @job_execution.gen_reqs_and_histories
      end
    end
  end
end
