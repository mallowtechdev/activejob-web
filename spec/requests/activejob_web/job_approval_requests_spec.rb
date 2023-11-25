# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivejobWeb::JobApprovalRequests', type: :request do
  before(:each) do
    @user = create(:user)
    sign_in @user
  end
  let(:job) { create(:job) }
  let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: @user.id) }
  let(:job_approval_request) { create(:job_approval_request, job_execution_id: job_execution.id, approver_id: @user.id) }
  describe 'GET #index' do
    it 'renders the index template' do
      get activejob_web_job_job_execution_job_approval_requests_path(job.id, job_execution.id)
      expect(response).to render_template('index')
      expect(response).to have_http_status 200
    end
  end

  describe 'GET #action' do
    context 'valid' do
      it 'renders action page with valid data' do
        get action_activejob_web_job_job_execution_job_approval_request_path(job.id, job_execution.id, job_approval_request.id)
        expect(response).to render_template('action')
        expect(response).to have_http_status 200
      end
    end

    context 'invalid' do
      it 'should not render action page with invalid data' do
        expect do
          get action_activejob_web_job_job_execution_job_approval_request_path(SecureRandom.uuid, 1, 1)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #update' do
    context 'valid' do
      it 'valid update of job approval request' do
        patch activejob_web_job_job_execution_job_approval_request_path(job, job_execution, job_approval_request),
              params: { activejob_web_job_approval_request: { response: 0, approver_comments: 'Test comments' } }
        job_approval_request.reload
        expect(job_approval_request.response).to eq(0)
        expect(job_approval_request.approver_comments).to eq('Test comments')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Job approval request updated successfully.')
        expect(response).to redirect_to(activejob_web_job_job_execution_job_approval_requests_path(job_approval_request))
      end
    end
  end
end
