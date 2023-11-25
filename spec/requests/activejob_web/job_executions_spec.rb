# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ActivejobWeb::JobExecutionsController, type: :request do
  before(:each) do
    @user = create(:user)
    sign_in @user
  end
  describe 'GET #index' do
    let(:job) { create(:job) } # Assuming you have a Job model

    it 'renders the index template' do
      get activejob_web_job_job_executions_path(job_id: job.id)

      expect(response).to have_http_status 200
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let(:job) { create(:job) }
    let(:execution) { create(:job_execution, job:, requestor_id: @user.id) }
    it 'renders the show template' do
      get activejob_web_job_job_execution_path(job_id: job.id, id: execution.id)
      expect(response).to have_http_status 200
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #edit' do
    let(:job) { create(:job) } # Assuming you have a Job factory
    let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: @user.id) } # Assuming you have a JobExecution factory

    it 'renders the edit template' do
      get edit_activejob_web_job_job_execution_path(job, job_execution)

      expect(response).to have_http_status 200
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    let(:job) { create(:job) }
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
    let(:job) { create(:job) } # Assuming you have a Job factory
    let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: @user.id) } # Assuming you have a JobExecution factory

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
end
