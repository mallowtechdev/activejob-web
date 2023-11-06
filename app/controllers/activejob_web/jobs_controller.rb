# frozen_string_literal: true

module ActivejobWeb
  class JobsController < ApplicationController
    before_action :set_job, only: %i[show edit update]

    def index
      @jobs = ActivejobWeb::Job.all
    end

    def show; end

    def edit; end

    def update
      @job.approvers << Activejob::Web.job_approvers_class.constantize.find(params.dig(:activejob_web_job, :approvers))
      @job.executors << Activejob::Web.job_executors_class.constantize.find(params.dig(:activejob_web_job, :executors))
      if @job.save
        redirect_to activejob_web_job_path(@job)
      else
        render :edit
      end
    end

    private

    def set_job
      @job = ActivejobWeb::Job.find(params[:id])
    end

    def job_params
      params.require(:activejob_web_job).permit(:title, :description, :approvers, :executors)
    end
  end
end
