# frozen_string_literal: true

module ActivejobWeb
  class JobsController < ApplicationController
    before_action :set_job, only: %i[show edit update]
    before_action :set_approvers_and_executors, only: %i[show edit]
    before_action :user_authorized?, only: %i[edit update]

    def index
      @jobs = ActivejobWeb::Job.joins(:approvers, :executors).where(activejob_web_job_executors: { executor_id: activejob_web_current_user.id })
                               .or(ActivejobWeb::Job.where(activejob_web_job_approvers: { approver_id: activejob_web_current_user.id }))
    end

    def show
      if @job.approvers.where(id: activejob_web_current_user.id).exists? || @job.executors.where(id: activejob_web_current_user.id).exists?
        render :show
      else
        redirect_to root_path
        flash[:notice] = 'You are not authorized to perform this action.'
      end
    end

    def edit
      @all_job_approvers = Activejob::Web.job_approvers_class.to_s.constantize.all
      @all_job_executors = Activejob::Web.job_executors_class.to_s.constantize.all
      render :edit
    end

    def update
      if @job.update(job_params)
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

    def set_approvers_and_executors
      @job_approvers = @job.approvers
      @job_executors = @job.executors
    end

    def user_authorized?
      return true if Activejob::Web.job_admins_class.constantize.active_job_admins.where(id: activejob_web_current_user.id).exists?

      redirect_to root_path
      flash[:notice] = 'You are not authorized to perform this action.'
    end

    def job_params
      params.require(:activejob_web_job).permit(approver_ids: [], executor_ids: [])
    end
  end
end
