class ActivejobWeb::JobExecutionsController < ApplicationController
  def index
    @job_executions = ActivejobWeb::JobExecution.all
     @new_job_execution = ActivejobWeb::JobExecution.new
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
def show
  @job_execution = ActivejobWeb::JobExecution.find(params[:id])
end
  def create
    @job_execution = ActivejobWeb::JobExecution.new
    @job_execution.assign_attributes(job_execution_params)

    if ActivejobWeb::Job.exists?(params[:job_id])
      @job_execution.activejob_web_jobs_id = params[:job_id]

      if @job_execution.save
        flash[:notice] = "Job execution created successfully."
        redirect_to activejob_web_job_job_executions_path
      else
        render :index
      end
    else
      flash[:error] = "The specified job does not exist."
      render :index
    end
end
  private
  def job_execution_params
    params.require(:activejob_web_job_execution).permit(:requestor_comments, :status, :run_at, :execution_started_at)
  end
end
