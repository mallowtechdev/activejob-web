class ActivejobWeb::JobsController < ApplicationController

  def index
    @jobs = ActivejobWeb::Job.all
  end

  def show
    @job = ActivejobWeb::Job.find(params[:id])
  end

  def download_pdf
    if @job.template_file.attached?
      send_file @job.template_file.download
    else
      flash[:error] = "Template file not found."
      redirect_to @job
    end
  end
end
