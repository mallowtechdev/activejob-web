# frozen_string_literal: true

module ActivejobWeb
  class JobExecutionsController < ApplicationController
    def index
      @job_executions = ActivejobWeb::JobExecution.where(job_id: params[:job_id])
      @job = ActivejobWeb::Job.find(params[:job_id])
      @new_job_execution = @job.job_executions.new
    end

    def create
      @job = ActivejobWeb::Job.find(params[:job_id])
      @job_execution = @job.job_executions.new(job_execution_params)
      if @job_execution.save!
        flash[:notice] = 'Job execution created successfully.'
        redirect_to activejob_web_job_job_executions_path
      else
        render :index
      end
    end

    def show
      @job_execution = ActivejobWeb::JobExecution.find(params[:id])
    end

    def edit
      @job_execution = ActivejobWeb::JobExecution.find(params[:id])
    end

    def update
      @job_execution = ActivejobWeb::JobExecution.find(params[:id])
      if @job_execution.update(job_execution_params)
        redirect_to job_execution_path(@job_execution), notice: 'Job execution was successfully updated.'
      else
        render :edit
      end
    end

    private

    def job_execution_params
      params.require(:activejob_web_job_execution).permit(:requestor_comments, :status, :run_at, :execution_started_at, :job_id,
                                                          :auto_execute_on_approval)
    end
  end
end
