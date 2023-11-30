# frozen_string_literal: true

module ActivejobWeb
  class JobExecutionsController < ApplicationController
    before_action :set_job_id
    def index
      @job_executions = ActivejobWeb::JobExecution.where(job_id: params[:job_id])
      @job_execution = @job.job_executions.new
    end

    def edit
      @job_execution = @job.job_executions.find(params[:id])
    end

    def update
      @job_execution = ActivejobWeb::JobExecution.find(params[:id])
      if @job_execution.update(job_execution_params)
        redirect_to activejob_web_job_job_execution_path(@job), notice: 'Job execution was successfully updated.'
      else
        render :edit
      end
    end

    def show
      @job_execution = ActivejobWeb::JobExecution.find(params[:id])
      @cancel_job_exec_status = @job_execution.cancel_execution
    end

    def create
      @job_execution = @job.job_executions.new(job_execution_params)
      @job_execution.requestor_id = current_user.id
      if @job_execution.save
        flash[:notice] = 'Job execution created successfully.'
        redirect_to activejob_web_job_job_executions_path(@job)
      else
        @job_executions = ActivejobWeb::JobExecution.where(job_id: params[:job_id])
        render :index
      end
    end

    def cancel
      @job_execution = ActivejobWeb::JobExecution.find(params[:id])
      @cancel_job_exec_status = @job_execution.cancel_execution == true
      if @cancel_job_exec_status
        @job_execution.update(status: 'cancelled')
        redirect_to activejob_web_job_job_executions_path(@job_execution.job)
        flash[:notice] = 'Job execution cancelled successfully.'
      else
        redirect_to activejob_web_job_job_execution_path(@job_execution.job)
        flash[:notice] = 'Unable to cancel job execution.'
      end
    end

    def reinitiate
      @job_execution = ActivejobWeb::JobExecution.find(params[:id])
      if @job_execution.status == 'cancelled'
        @job_execution.update(status: 'requested')
        @job_execution.revoke_approval_requests
        redirect_to activejob_web_job_job_executions_path(@job_execution.job)
        flash[:notice] = 'Job execution Reinitiated successfully.'
      else
        redirect_to activejob_web_job_job_execution_path(@job_execution.job)
        flash[:notice] = 'Unable to Reinitiate job execution.'
      end
    end
  end
end

  private

def job_execution_params
  params.require(:activejob_web_job_execution).permit(:requestor_comments, :status, :job_id, :auto_execute_on_approval)
end

def set_job_id
  @job = ActivejobWeb::Job.find(params[:job_id])
end
