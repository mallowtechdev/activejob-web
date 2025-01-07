# frozen_string_literal: true

module Activejob
  module Web
    class JobsController < ApplicationController
      before_action :set_job, only: %i[show edit update]
      before_action :set_job_users, only: %i[show edit update]
      before_action :set_all_users, only: %i[edit update new]

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

      def new
        @job = Activejob::Web::Job.new
        @activejob_web_job_names = fetch_job_names
      end

      def edit; end

      def update
        if @job.update(job_params)
          redirect_to activejob_web_job_path(@job), notice: 'Job was successfully updated.'
        else
          render :edit
        end
      end

      def create
        job_attributes = {
          title: job_params[:title], description: job_params[:description], input_arguments: job_params[:input_arguments].present? ? JSON.parse(job_params[:input_arguments]) : nil,
          max_run_time: job_params[:max_run_time], minimum_approvals_required: job_params[:minimum_approvals_required],
          priority: job_params[:priority], job_name: job_params[:job_name], approver_ids: job_params[:approver_ids], executor_ids: job_params[:executor_ids]
        }

        @job = Activejob::Web::Job.new(job_attributes)

        begin
          @job.save!
          flash[:notice] = 'Job created successfully.'
          redirect_to activejob_web_jobs_path
        rescue ActiveRecord::RecordInvalid => e
          flash[:error] = "Failed to create job: #{e.message}"
          render :new
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
          @all_approvers = @all_approvers.where('email LIKE ?', "%#{email}%") if email.present?
          @all_approvers = @all_approvers.offset((page - 1) * per_page).limit(per_page)
          response_data = { approvers: @all_approvers.map(&:attributes) }
        elsif user_type == 'executor'
          @all_executors = if Activejob::Web.is_common_model
                             Activejob::Web::Approver.select(:id, :email)
                           else
                             Activejob::Web::Executor.select(:id, :email)
                           end
          @all_executors = @all_executors.where('email LIKE ?', "%#{email}%") if email.present?
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
        params.require(:activejob_web_job).permit(
          :title, :description, :max_run_time, :minimum_approvals_required, :priority, :job_name, :input_arguments,
          approver_ids: [], executor_ids: []
        )
      end

      def fetch_job_names(exclude_files: ['application_job'], fallback_job_names: %w[Testing::Job::Name Demo::Job::Name])
        job_files_path = Rails.root.join('app', 'jobs', 'activejob', 'web', '*.rb')
        job_names = Dir[job_files_path].map do |file_path|
          file_name = File.basename(file_path, '.rb')
          next if exclude_files.include?(file_name)

          file_name.camelize
        end.compact

        job_names.presence || fallback_job_names
      end
    end
  end
end
