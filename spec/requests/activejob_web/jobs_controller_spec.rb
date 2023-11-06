# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Jobs', type: :request do
  describe 'GET #edit' do
    let(:job) { ActivejobWeb::Job.create(title: 'Activejob', description: 'Web Gem') }
    context 'valid' do
      it 'valid edit' do
        get edit_activejob_web_job_path(job.id)
        expect(response).to have_http_status 200
      end
    end

    context 'invalid' do
      it 'invalid edit without parameters' do
        data = ActivejobWeb::Job.create(description: 'Web Gem')
        expect { get edit_activejob_web_job_path(data.id) }.to raise_error(ActionController::UrlGenerationError)
      end
    end
  end

  describe 'PATCH #update' do
    context 'valid' do
      it 'valid update of job and redirect to show page' do
        job = ActivejobWeb::Job.create(title: 'Activejob', description: 'Web Gem')
        approver = User.create(name: 'Test approver')
        executor = User.create(name: 'Test executor')

        put :update, params: { id: job.id, activejob_web_job: { approvers: approver, executors: executor } }

        job.reload
        expect(job.approvers).to eq(approver)
        expect(response).to redirect_to(activejob_web_job_path(job))
      end
    end
  end
end
