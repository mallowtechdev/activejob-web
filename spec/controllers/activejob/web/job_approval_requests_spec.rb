# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::JobApprovalRequestsController, type: :controller do
  include_context 'common setup'

  let(:source_admin) { create(:source_admin) }
  let(:source_approver) { create(:source_approver) }
  let(:source_approver_two) { create(:source_approver_two) }
  let(:approver) { create(:approver) }
  let(:source_executor) { create(:source_executor) }
  let(:executor) { create(:executor) }
  let(:job) { create(:job, minimum_approvals_required: 2) }

  before do
    job.approver_ids = [source_approver.id, source_approver_two.id]
    job.executor_ids = [source_executor.id]
    job.save
    allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
    allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
  end

  describe 'GET #index' do
    before do
      create(:job_execution, job:, requestor_id: source_executor.id)
    end

    it 'renders the index template' do
      get :index, params: { job_id: job.id }
      expect(response).to render_template(:index)
    end

    context 'when the user is an admin' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
      end

      it 'assigns all job approval requests' do
        get :index, params: { job_id: job.id }
        expect(assigns(:job_approval_requests).count).to eq(2)
      end
    end

    context 'when the user is an approver' do
      it 'assigns only the job approval requests for the approver' do
        get :index, params: { job_id: job.id }
        expect(assigns(:job_approval_requests).count).to eq(1)
      end
    end

    context 'when the user is unauthorized' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      end

      it 'redirects to the root path with an alert' do
        get :index, params: { job_id: job.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'GET #show' do
    context 'when the user is an approver' do
      let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: source_executor.id) }

      it 'render the show template' do
        approval_request = job_execution.job_approval_requests.find_by(approver_id: source_approver.id)
        get :show, params: { job_id: job.id, id: approval_request.id }
        expect(response).to render_template(:show)
      end

      it 'raises an error if the record is not found' do
        approval_request = job_execution.job_approval_requests.where.not(approver_id: source_approver.id).first
        expect do
          get :show, params: { job_id: job.id, id: approval_request.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:execution) { create(:job_execution, job:, requestor_id: source_executor.id) }

      it 'updates the job approval request and redirects to the index page' do
        approval_request = execution.job_approval_requests.find_by(approver_id: source_approver.id)
        patch :update, params: {
          job_id: job.id,
          id: approval_request.id,
          activejob_web_job_approval_request: { response: 'approved', approver_comments: 'test' }
        }

        expect(flash[:notice]).to eq('Job approval request was successfully updated.')
        expect(response).to redirect_to(activejob_web_job_job_approval_requests_path(job))
      end
    end

    context 'with invalid parameters' do
      let(:execution) { create(:job_execution, job:, requestor_id: source_executor.id) }

      it 'does not update the job execution and renders the edit template' do
        approval_request = execution.job_approval_requests.find_by(approver_id: source_approver.id)
        allow_any_instance_of(Activejob::Web::JobApprovalRequest).to receive(:update).and_return(false)

        patch :update, params: {
          job_id: job.id,
          id: approval_request.id,
          activejob_web_job_approval_request: { response: 'approved', approver_comments: nil }
        }

        expect(response).to render_template(:show)
      end
    end
  end
end
