# frozen_string_literal: true

module ActivejobWeb
  class JobsController < ApplicationController
    include ActivejobWeb::JobsHelper
    before_action :set_job, only: %i[show edit update]

    def index
      @jobs = ActivejobWeb::Job.includes(:executors).where(activejob_web_job_executors: { executor_id: activejob_web_current_user.id })
    end

    def show
      if @job.executors.include?(activejob_web_current_user)
        render :show
      else
        redirect_to root_path
        flash[:notice] = 'You are not authorized to perform this action.'
      end
    end

    def edit; end

    def update
      @job.approver_ids = job_params[:approver_ids]
      @job.executor_ids = job_params[:executor_ids]
      if @job.save
        redirect_to activejob_web_job_path(@job)
        flash[:notice] = 'Job was successfully updated.'
      else
        render :edit
      end
    end

    private

    def set_job
      @job = ActivejobWeb::Job.find(params[:id])
    end

    def job_params
      params.require(:activejob_web_job).permit(approver_ids: [], executor_ids: [])
    end
  end
end
