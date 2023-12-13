# frozen_string_literal: true

module ActivejobWeb
  class JobsController < ApplicationController
    before_action :set_job, only: %i[show edit update]
    before_action :set_approvers_and_executors, only: %i[show edit]

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

    def edit
      if user_authorized?
        render :edit
      else
        redirect_to root_path
        flash[:notice] = 'You are not authorized to perform this action.'
      end
    end

    def update
      if user_authorized?
        @job.update(job_params)
        if @job.save
          redirect_to activejob_web_job_path(@job)
          flash[:notice] = 'Job was successfully updated.'
        else
          render :edit
        end
      else
        redirect_to root_path
        flash[:notice] = 'You are not authorized to perform this action.'
      end
    end

    private

    def set_job
      @job = ActivejobWeb::Job.find(params[:id])
    end

    def set_approvers_and_executors
      @job_approvers = @job.approvers
      @job_executors = @job.executors
      @all_job_approvers = Activejob::Web.job_approvers_class.to_s.constantize.all
      @all_job_executors = Activejob::Web.job_executors_class.to_s.constantize.all
    end

    def user_authorized?
      Activejob::Web.job_approvers_class.constantize.super_admin_users.include?(activejob_web_current_user)
    end

    def job_params
      params.require(:activejob_web_job).permit(approver_ids: [], executor_ids: [])
    end
  end
end
