class ActivejobWebJobsController < ApplicationController

  def index
    @activejob_web_jobs = ActivejobWebJob.all
  end

  def show
    @activejob_web_job = ActivejobWebJob.find(params[:id])
  end

  def download_pdf
    if @activejob_web_job.template_file.attached?
      send_file @activejob_web_job.template_file.download
    else
      flash[:error] = "Template file not found."
      redirect_to @activejob_web_job
    end
  end
end
