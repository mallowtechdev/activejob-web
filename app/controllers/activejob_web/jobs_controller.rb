class ActivejobWeb::JobsController < ApplicationController
  before_action :set_job, only: %i[show edit]

  def index
    @jobs = ActivejobWeb::Job.all
  end

  def show; end

  def edit; end

  private

  def set_job
    @job = ActivejobWeb::Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :job_approvers, :job_executors)
  end
end
