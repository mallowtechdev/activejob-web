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
      @job.approver_ids = params.dig(:activejob_web_job, :approver_ids).compact_blank.map(&:to_i)
      @job.executor_ids = params.dig(:activejob_web_job, :executor_ids).compact_blank.map(&:to_i)
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
  end
end
