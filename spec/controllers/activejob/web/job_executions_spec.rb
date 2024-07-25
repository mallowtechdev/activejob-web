# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::JobExecutionsController, type: :controller do
  include_context 'common setup'

  let(:source_admin) { create(:source_admin) }
  let(:source_approver) { create(:source_approver) }
  let(:source_executor) { create(:source_executor) }
  let(:executor) { create(:executor) }
  let(:job) { create(:job, minimum_approvals_required: 1) }

  before do
    job.approver_ids = [source_approver.id]
    job.executor_ids = [source_executor.id]
    job.save
    allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
    allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
  end

  describe 'GET #index' do
    before do
      create(:job_execution, job_id: job.id, requestor_id: source_executor.id)
      create(:job_execution, job_id: job.id, requestor_id: executor.id)
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

      it 'assigns all job executions' do
        get :index, params: { job_id: job.id }
        expect(assigns(:job_executions).count).to eq(2)
      end
    end

    context 'when the user is an executor' do
      it 'assigns only the job executions for the executor' do
        get :index, params: { job_id: job.id }
        expect(assigns(:job_executions).count).to eq(1)
      end
    end

    context 'when the user is unauthorized' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
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
    context 'when the user is an executor' do
      it 'renders the show template' do
        job_execution = create(:job_execution, job_id: job.id, requestor_id: source_executor.id)
        get :show, params: { job_id: job.id, id: job_execution.id }
        expect(response).to render_template(:show)
      end

      it 'assigns histories and requests' do
        job_execution = create(:job_execution, job_id: job.id, requestor_id: source_executor.id)
        get :show, params: { job_id: job.id, id: job_execution.id }
        expect(assigns(:job_execution_histories).count).to eq(1)
        expect(assigns(:job_approval_requests).count).to eq(1)
      end

      it 'raises an error if the record is not found' do
        job_execution = create(:job_execution, job_id: job.id, requestor_id: executor.id)
        expect do
          get :show, params: { job_id: job.id, id: job_execution.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #edit' do
    context 'when the user is an executor' do
      it 'renders the edit template' do
        job_execution = create(:job_execution, job_id: job.id, requestor_id: source_executor.id)
        get :edit, params: { job_id: job.id, id: job_execution.id }
        expect(response).to render_template(:edit)
      end

      it 'raises an error if the record is not found' do
        job_execution = create(:job_execution, job_id: job.id, requestor_id: executor.id)
        expect do
          get :edit, params: { job_id: job.id, id: job_execution.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_execution_attributes) { attributes_for(:job_execution) }

      it 'creates a new job execution and redirects' do
        expect do
          post :create, params: {
            job_id: job.id,
            arguments: valid_execution_attributes[:arguments],
            activejob_web_job_execution: valid_execution_attributes.merge(requestor_id: source_executor.id)
          }
        end.to change(Activejob::Web::JobExecution, :count).by(1)

        expect(flash[:notice]).to eq('Job execution was successfully created.')
        expect(response).to redirect_to(activejob_web_job_job_executions_path(job))
        expect(Activejob::Web::JobExecution.last.job_approval_requests.count).to eql(1)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_execution_attributes) { attributes_for(:job_execution) }

      it 'does not create a new job execution and renders the index template' do
        expect do
          post :create, params: {
            job_id: job.id,
            activejob_web_job_execution: invalid_execution_attributes.merge(requestor_comments: nil)
          }
        end.not_to change(Activejob::Web::JobExecution, :count)

        expect(response).to render_template(:index)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:execution) { create(:job_execution, job:, requestor_id: source_executor.id) }

      it 'updates the job execution and redirects to the show page' do
        patch :update, params: {
          job_id: job.id,
          id: execution.id,
          activejob_web_job_execution: { status: 'requested' }
        }

        expect(flash[:notice]).to eq('Job execution was successfully updated.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job, execution))
        expect(execution.reload.status).to eq('requested')
      end
    end

    context 'with invalid parameters' do
      let(:execution) { create(:job_execution, job:, requestor_id: source_executor.id) }

      it 'does not update the job execution and renders the edit template' do
        patch :update, params: {
          job_id: job.id,
          id: execution.id,
          activejob_web_job_execution: { requestor_comments: nil }
        }

        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'PATCH #cancel' do
    let(:execution) { create(:job_execution, job:, requestor_id: source_executor.id) }

    context 'when the job_execution cancel is valid' do
      it 'cancels the job_execution if it is in the requested state' do
        patch :cancel, params: { job_id: job.id, id: execution.id }
        execution.reload
        expect(execution.status).to eq('cancelled')
        expect(flash[:notice]).to eq('Job execution was successfully cancelled.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job, execution))
      end

      it 'does not create new execution history and only update existing' do
        patch :cancel, params: { job_id: job.id, id: execution.id }
        expect(execution.job_execution_histories.count).to eq(1)
        expect(execution.current_execution_history.details['status']).to eq('cancelled')
      end

      it 'delete existing approval requests' do
        expect(execution.job_approval_requests.count).to eq(1)
        patch :cancel, params: { job_id: job.id, id: execution.id }
        expect(execution.job_approval_requests.count).to eq(0)
      end
    end

    context 'when the job_execution cancel is not valid' do
      it 'does not cancel the job_execution if it is not in the cancel_execution state' do
        execution.update(status: 'executed', execution_started_at: Time.now)
        patch :cancel, params: { job_id: job.id, id: execution.id }
        execution.reload
        expect(execution.status).to eq('executed')
        expect(flash[:alert]).to eq('Failed to cancel job execution.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job, execution))
      end
    end
  end

  describe 'PATCH #reinitiate' do
    let(:execution) { create(:job_execution, job:, requestor_id: source_executor.id, status: 'cancelled') }

    context 'when the job_execution reinitiate is valid' do
      it 'reinitiate the job_execution if it is in the cancelled state' do
        patch :reinitiate, params: { job_id: job.id, id: execution.id }
        execution.reload
        expect(execution.status).to eq('requested')
        expect(flash[:notice]).to eq('Job execution was successfully reinitiated.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job, execution))
      end

      it 'does not create new execution history and only update existing' do
        patch :reinitiate, params: { job_id: job.id, id: execution.id }
        expect(execution.job_execution_histories.count).to eq(1)
        expect(execution.current_execution_history.details['status']).to eq('requested')
      end

      it 'create new approval requests' do
        expect(execution.job_approval_requests.count).to eq(1)
        execution.update(status: 'requested')
        patch :cancel, params: { job_id: job.id, id: execution.id }
        expect(execution.job_approval_requests.count).to eq(0)
        patch :reinitiate, params: { job_id: job.id, id: execution.id }
        expect(execution.job_approval_requests.count).to eq(1)
      end
    end

    context 'when the job_execution reinitiate is not valid' do
      it 'does not reinitiate the job_execution if it is not in the cancelled state' do
        execution.update(status: 'requested', execution_started_at: Time.now)
        patch :reinitiate, params: { job_id: job.id, id: execution.id }
        execution.reload
        expect(execution.status).to eq('requested')
        expect(flash[:alert]).to eq('Failed to reinitiate job execution.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job, execution))
      end
    end
  end

  describe 'PATCH #execute' do
    let(:job_execution) { create(:job_execution, job:, requestor_id: source_executor.id) }
    context 'when job execution is successful' do
      before do
        allow_any_instance_of(Activejob::Web::JobExecution).to receive(:execute).and_return(true)
      end

      it 'sets a success flash message and redirects to the job execution show page' do
        patch :execute, params: { job_id: job.id, id: job_execution.id }
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job, job_execution))
        expect(flash[:notice]).to eq('Job execution was successfully executed.')
      end
    end

    context 'when job execution fails' do
      before do
        allow_any_instance_of(Activejob::Web::JobExecution).to receive(:execute).and_return(false)
      end

      it 'sets a failure flash message and redirects to the job execution show page' do
        patch :execute, params: { job_id: job.id, id: job_execution.id }
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job, job_execution))
        expect(flash[:alert]).to eq('Failed to execute job execution.')
      end
    end
  end
end
