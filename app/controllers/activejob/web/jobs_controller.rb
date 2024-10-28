# frozen_string_literal: true

module Activejob
  module Web
    class JobsController < ApplicationController
      before_action :set_job, only: %i[show edit update]
      before_action :set_job_users, only: %i[show edit update]
      before_action :set_all_users, only: %i[edit update]

      def index
        if !admin? && Activejob::Web.is_common_model
          @approval_jobs = @activejob_web_current_user.approver_jobs
          @execution_jobs = @activejob_web_current_user.executor_jobs
        else
          @jobs = @activejob_web_current_user.jobs
        end
        @pending_approvals = Activejob::Web::JobApprovalRequest
                               .includes(:approver, job_execution: %i[job executor])
                               .pending_requests(admin?, @activejob_web_current_user.id)
      end

      def show; end

      def edit; end

      def update
        if @job.update(job_params)
          redirect_to activejob_web_job_path(@job)
          flash[:notice] = 'Job was successfully updated.'
        else
          render :edit
        end
      end

      def download_pdf
        if @job.template_file.attached?
          send_file @job.template_file.download
        else
          flash[:error] = 'Template file not found.'
          redirect_to @job
        end
      end

      def load_more_users
        user_type = params[:type]
        email = params[:email]
        page = params[:page].to_i
        per_page = 10

        if user_type == 'approver'
          @all_approvers = Activejob::Web::Approver.select(:id, :email)
          @all_approvers = @all_approvers.where("email LIKE ?", "%#{email}%") if email.present?
          @all_approvers = @all_approvers.offset((page - 1) * per_page).limit(per_page)
          response_data = { approvers: @all_approvers.map(&:attributes) }
        elsif user_type == 'executor'
          @all_executors = if Activejob::Web.is_common_model
                             Activejob::Web::Approver.select(:id, :email)
                           else
                             Activejob::Web::Executor.select(:id, :email)
                           end
          @all_executors = @all_executors.where("email LIKE ?", "%#{email}%") if email.present?
          @all_executors = @all_executors.offset((page - 1) * per_page).limit(per_page)
          response_data = { executors: @all_executors.map(&:attributes) }
        end

        render json: response_data
      end

      private

      def set_job
        @job = @activejob_web_current_user.jobs.find(params[:id])
      end

      def set_job_users
        @approvers, @executors =
          %w[approver executor].map do |user_type|
            @job.public_send("#{user_type}s").pluck(:email)
          end
      end

      def set_all_users
        @all_approvers = Activejob::Web::Approver.select(:id, :email).limit(10)
        @all_executors = if Activejob::Web.is_common_model
                           @all_approvers
                         else
                           Activejob::Web::Executor.select(:id, :email).limit(10)
                         end
      end

      def job_params
        params.require(:activejob_web_job).permit(approver_ids: [], executor_ids: [])
      end
    end
  end
end
