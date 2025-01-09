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
        request_data = { start_from_head: true, start_time: params[:event_timestamp].to_i }.compact
        event_response = @job_execution_history.log_events(nil, request_data)
        log_events = event_response.present? ? event_response.events : []
        last_event = log_events&.last
        filtered_logs = filter_log_events(log_events)

        response = build_response(filtered_logs, last_event)
        response.merge!({ terminated: true }) if last_event.present? && last_event.message.include?('JOB ENDED') && filtered_logs.blank?

        render json: response
      end

      def local_logs
        response = { messages: [], last_index: 0 }
        begin
          process_log_file(file_path: params[:file_path], last_index: params[:last_index].to_i, response: response)
        rescue Errno::ENOENT
          response[:messages] = []
          Rails.logger.info 'Local Log file not found - Error while reading local logs and returning empty response'
        rescue StandardError => e
          Rails.logger.info "Error while fetching local logs - Error: #{e.message}"
        end

        render json: response
      end

      private

      def process_log_file(file_path:, last_index:, response:)
        File.open(file_path, 'r') do |file|
          file.each_with_index do |line, index|
            next if last_index.positive? && index <= last_index

            response[:messages] << line
            response[:last_index] = index
          end
        end

        response[:terminated] = true if response[:messages].last&.include?('JOB ENDED')
      end

      def job_execution_params
        params.require(:activejob_web_job_execution)
              .permit(:requestor_id, :requestor_comments, :status, :job_id, :auto_execute_on_approval, input_file:[])
      end

      def set_job
        @job = @activejob_web_current_user.jobs.find(params[:job_id])
      end

      def set_job_execution
        @job_execution = @job.job_executions.find_by!(id: params[:id], requestor_id: @activejob_web_current_user.id)
      end

      def set_job_execution_history
        @job_execution_history = @job_execution.job_execution_histories.find(params['history_id'])
      end

      def user_authorized?
        return true if admin? || @job.executor_ids.include?(@activejob_web_current_user.id)

        redirect_to root_path, alert: 'You are not authorized to perform this action'
      end

      def update_with_source_params(source_params)
        source_status = source_params[:status]
        source_params[:status] = source_status == 'reinitiate' ? 'requested' : source_status
        source_params.merge!({ execution_started_at: nil, run_at: nil, reason_for_failure: nil })

        @job_execution.update(source_params) && @job_execution.gen_reqs_and_histories(reinitiate: source_status == 'reinitiate')
      end

      def filter_log_events(log_events)
        return log_events unless params[:event_ingestion].present?

        log_events.select { |log_event| log_event.ingestion_time > params[:event_ingestion].to_i }
      end

      def build_response(filtered_logs, last_event)
        {
          messages: filtered_logs&.map(&:message).presence || [],
          event_timestamp: last_event&.timestamp || params[:event_timestamp],
          event_ingestion: last_event&.ingestion_time || params[:event_ingestion]
        }
      end
    end
  end
end
