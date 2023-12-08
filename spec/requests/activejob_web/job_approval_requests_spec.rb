# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivejobWeb::JobApprovalRequests', type: :request do
  let(:job) { create(:job) }
  let(:user) { create(:user) }
  let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: user.id) }
  let(:job_approval_request) { create(:job_approval_request, job_execution_id: job_execution.id, approver_id: user.id) }
  before do
    allow_any_instance_of(ActivejobWeb::JobsHelper).to receive(:activejob_web_current_user).and_return(user)
  end
  describe 'GET #index' do
    context 'valid index page' do
      it 'valid list of approval requests in the index page' do
        job_approval_request
        get activejob_web_job_job_execution_job_approval_requests_path(job, job_execution)
        expect(response).to render_template('index')
        expect(response).to have_http_status 200
        expect(assigns(:job_approval_requests).count).to eql 1
      end
    end

    context 'invalid index page' do
      let(:user2) { create(:approver) }
      it 'should not show invalid list of approval requests in the index page' do
        job_approval_request.update(approver_id: user2.id)
        get activejob_web_job_job_execution_job_approval_requests_path(job, job_execution)
        expect(response).to render_template('index')
        expect(response).to have_http_status 200
      end
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
              params: { activejob_web_job_approval_request: { response: 'declined', approver_comments: 'Test comments' } }
        job_approval_request.reload
        expect(job_approval_request.response).to eq('declined')
        expect(job_approval_request.approver_comments).to eq('Test comments')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Job approval request updated successfully.')
        expect(response).to redirect_to(activejob_web_job_job_execution_job_approval_requests_path(job, job_execution))
      end
    end
  end
end
