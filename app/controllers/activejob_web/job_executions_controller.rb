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
    end

    def create
      @job_execution = @job.job_executions.new(job_execution_params)
      @job_execution.requestor_id = activejob_web_current_user.id
      if @job_execution.save
        flash[:notice] = 'Job execution created successfully.'
        redirect_to activejob_web_job_job_executions_path(@job)
      else
        @job_executions = ActivejobWeb::JobExecution.where(job_id: params[:job_id])
        render :index
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
