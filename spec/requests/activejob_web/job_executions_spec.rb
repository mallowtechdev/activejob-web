# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ActivejobWeb::JobExecutionsController, type: :request do
  before(:each) do
    @user = create(:user)
    sign_in @user
  end
  let(:job) { create(:job) }
  let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: @user.id) }
  describe 'GET #index' do
    let(:job) { create(:job) } # Assuming you have a Job model

    it 'renders the index template' do
      get activejob_web_job_job_executions_path(job_id: job.id)

      expect(response).to have_http_status 200
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get activejob_web_job_job_execution_path(job_id: job.id, id: job_execution.id)
      expect(response).to have_http_status 200
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get edit_activejob_web_job_job_execution_path(job, job_execution)

      expect(response).to have_http_status 200
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_execution_attributes) { attributes_for(:valid_job_execution) }

      it 'creates a new job execution' do
        post activejob_web_job_job_executions_path(job), params: {
          activejob_web_job_execution: valid_execution_attributes
        }

        expect(response).to have_http_status(302) # Redirect status
        expect(flash[:notice]).to eq('Job execution created successfully.')
        expect(response).to redirect_to(activejob_web_job_job_executions_path(job))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_execution_attributes) { attributes_for(:invalid_job_execution) }

      it 'renders the index template' do
        post activejob_web_job_job_executions_path(job), params: {
          activejob_web_job_execution: invalid_execution_attributes
        }

        expect(response).to have_http_status(200) # Success status since it renders the index template
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      it 'updates the job execution and redirects to the show page' do
        patch activejob_web_job_job_execution_path(job, job_execution),
              params: { activejob_web_job_execution: { status: 'requested' } }

        expect(response).to have_http_status 302 # Redirect status
        expect(flash[:notice]).to eq('Job execution was successfully updated.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job))
      end
    end
  end

  describe 'PATCH #cancel' do
    context 'valid job_execution cancel' do
      it 'should cancel the job_execution if it is in requested state' do
        patch cancel_activejob_web_job_job_execution_path(job, job_execution)
        job_execution.reload
        expect(job_execution.status).to eq('cancelled')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Job execution cancelled successfully.')
        expect(response).to redirect_to(activejob_web_job_job_executions_path(job))
      end

      it 'should cancel the job_execution if it is in approved state but execution not started yet' do
        job_execution.update(status: 'approved', execution_started_at: nil)
        patch cancel_activejob_web_job_job_execution_path(job, job_execution)
        job_execution.reload
        expect(job_execution.status).to eq('cancelled')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Job execution cancelled successfully.')
        expect(response).to redirect_to(activejob_web_job_job_executions_path(job))
      end
    end

    context 'invalid job_execution cancel' do
      it 'should not cancel the job_execution if the state is other than requested or approved' do
        job_execution.update(status: 'rejected')
        patch cancel_activejob_web_job_job_execution_path(job, job_execution)
        job_execution.reload
        expect(job_execution.status).not_to eq('cancelled')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Unable to cancel job execution.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job))
      end

      it 'should not cancel the job_execution if the state is approved and the execution is started' do
        job_execution.update(status: 'approved', execution_started_at: Time.current)
        patch cancel_activejob_web_job_job_execution_path(job, job_execution)
        job_execution.reload
        expect(job_execution.status).not_to eq('cancelled')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Unable to cancel job execution.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job))
      end
    end
  end

  describe 'POST #reinitiate' do
    context 'valid reinitiate job execution' do
      it 'should reinitiate the job execution if the state is cancelled' do
        job_execution.update(status: 'cancelled')
        post reinitiate_activejob_web_job_job_execution_path(job, job_execution)
        job_execution.reload
        expect(job_execution.status).to eq('requested')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Job execution Reinitiated successfully.')
        expect(response).to redirect_to(activejob_web_job_job_executions_path(job))
      end
    end

    context 'invalid reinitiate job execution' do
      it 'should not reinitiate the job execution if the state is other than cancelled' do
        job_execution.update(status: 'approved')
        post reinitiate_activejob_web_job_job_execution_path(job, job_execution)
        job_execution.reload
        expect(job_execution.status).not_to eq('requested')
        expect(response).to have_http_status 302
        expect(flash[:notice]).to eq('Unable to Reinitiate job execution.')
        expect(response).to redirect_to(activejob_web_job_job_execution_path(job))
      end
    end
  end
end
