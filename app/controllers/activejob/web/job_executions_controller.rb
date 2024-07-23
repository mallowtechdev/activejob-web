# frozen_string_literal: true

module Activejob
  module Web
    class JobExecutionsController < ApplicationController
      before_action :set_job
      before_action :user_authorized?
      before_action :set_job_execution, except: %i[index create]
      before_action :set_job_execution_history, only: %i[logs live_logs local_logs]

      def index
        @job_executions = @job.job_executions.includes(:job_approval_requests)
                              .where(admin? ? nil : { requestor_id: @activejob_web_current_user.id })
        @job_execution = Activejob::Web::JobExecution.new(job_id: @job.id)
      end

      def show
        @job_execution_histories = @job_execution.job_execution_histories
        @job_approval_requests = Activejob::Web::JobApprovalRequest.includes(:approver).where(job_execution_id: @job_execution.id)
      end

      def edit; end

      def update
        @job_execution.arguments = params['arguments']
        if update_with_source_params(job_execution_params.merge({ status: 'requested' }))
          redirect_to activejob_web_job_job_execution_path(@job), notice: 'Job execution was successfully updated.'
        else
          render :edit
        end
      end

      def create
        @job_execution = @job.job_executions.new(job_execution_params)
        @job_execution.arguments = params['arguments']
        @job_execution.requestor_id = @activejob_web_current_user.id if !admin? && @job_execution.requestor_id.nil?
        if @job_execution.save
          redirect_to activejob_web_job_job_executions_path(@job), notice: 'Job execution was successfully created.'
        else
          render :index
        end
      end

      def cancel
        if @job_execution.cancel_execution && update_with_source_params({ status: 'cancelled' })
          flash[:notice] = 'Job execution was successfully cancelled.'
        else
          flash[:alert] = 'Failed to cancel job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def reinitiate
        if @job_execution.cancelled? && update_with_source_params({ status: 'reinitiate' })
          flash[:notice] = 'Job execution was successfully reinitiated.'
        else
          flash[:alert] = 'Failed to reinitiate job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def execute
        if @job_execution.execute
          flash[:notice] = 'Job execution was successfully executed.'
        else
          flash[:alert] = 'Failed to execute job execution.'
        end
        redirect_to activejob_web_job_job_execution_path(@job, @job_execution)
      end

      def history
        @job_execution_histories = @job_execution.job_execution_histories.includes(input_file_attachment: [:blob])
      end

      def logs; end

      def live_logs
        request_data = { start_from_head: true }
        event_timestamp = params[:event_timestamp]
        event_ingestion = params[:event_ingestion]
        request_data.merge!({ start_time: event_timestamp }) if event_timestamp.present?

        event_response = @job_execution_history.log_events(nil, request_data)

        log_events = event_response.events if event_response.present?
        last_event = log_events.present? ? log_events.last : nil

        filtered_logs = if log_events.present? && event_ingestion.present?
                          log_events.select { |log_event| log_event.ingestion_time > event_ingestion.to_i }
                        elsif log_events.present?
                          log_events
                        else
                          []
                        end

        response = {
          messages: filtered_logs&.map(&:message),
          event_timestamp: last_event.present? ? last_event.timestamp : event_timestamp,
          event_ingestion: last_event.present? ? last_event.ingestion_time : event_ingestion,
        }
        response.merge!({ terminated: true }) if last_event.present? && last_event.message.include?("JOB ENDED") && filtered_logs.blank?

        render json: response
      end

      def local_logs
        begin
          response = {}
          messages = []

          file_path = params[:file_path]
          last_index = params[:last_index].to_i || 0
          File.open(file_path, 'r') do |file|
            file.each_with_index do |line, index|
              next if last_index != 0 && index <= last_index

              messages << line
              last_index = index
            end
          end

          response.merge!(terminated: true) if messages.present? && messages.last.include?("JOB ENDED")
          response.merge!(messages:, last_index:)
        rescue Errno::ENOENT
          response.merge!(messages: [])
          puts 'Local Log file not found - Error while reading local logs and returning empty response'
        rescue StandardError => e
          puts "Error while fetching local logs - Error: #{e.message}"
        end

        render json: response
      end

      private

      def job_execution_params
        params.require(:activejob_web_job_execution).permit(:requestor_id, :requestor_comments, :status, :job_id, :auto_execute_on_approval, :arguments, :input_file)
      end

      def set_job
        @job = @activejob_web_current_user.jobs.find(params[:job_id])
      end

      def set_job_execution
        @job_execution = @job.job_executions.find(params[:id])
      end

      def set_job_execution_history
        @job_execution_history = @job_execution.job_execution_histories.find_by(id: params['history_id'])
      end

      def user_authorized?
        redirect_to root_path, alert: 'You are not authorized to perform this action' unless admin? || @job.executor_ids.include?(@activejob_web_current_user.id)
      end

      def update_with_source_params(source_params)
        source_status = source_params[:status]
        source_params[:status] = source_status == 'reinitiate' ? 'requested' : source_status
        source_params.merge!({ execution_started_at: nil, run_at: nil, reason_for_failure: nil })

        @job_execution.update(source_params) && @job_execution.gen_reqs_and_histories(reinitiate: source_status == 'reinitiate')
      end
    end
  end
end
