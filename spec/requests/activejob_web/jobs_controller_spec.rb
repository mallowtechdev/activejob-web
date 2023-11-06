# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivejobWeb::JobsController, type: :request do
  let(:valid_attributes) { { title: 'Activejob', description: 'Web Gem' } }
  describe 'GET #edit' do
    let(:job) { ActivejobWeb::Job.create(valid_attributes) }
    context 'valid' do
      it 'valid edit' do
        get edit_activejob_web_job_path(job.id)
        expect(response).to have_http_status 200
      end
    end

    context 'invalid' do
      it 'invalid edit without parameters' do
        job = ActivejobWeb::Job.create(description: 'Web Gem')
        expect { get edit_activejob_web_job_path(job.id) }.to raise_error(ActionController::UrlGenerationError)
      end
    end
  end

  describe 'PATCH #update' do
    let(:job) { ActivejobWeb::Job.create(valid_attributes) }
    let(:approver) { User.create(name: 'Test approver') }
    let(:executor) { User.create(name: 'Test executor') }
    context 'valid' do
      it 'valid update of job with approvers and executors' do
        patch activejob_web_job_path(job.id),
              params: { id: job.id, activejob_web_job: valid_attributes.merge(approvers: approver.id, executors: executor.id) }
        job.reload
        expect(response).to redirect_to(activejob_web_job_path(job))
        expect(job.approvers).to include(approver)
        expect(job.executors).to include(executor)
      end
    end

    context 'invalid' do
      it 'invalid update of job without approvers and executors' do
        expect do
          patch activejob_web_job_path(job.id),
                params: { id: job.id, activejob_web_job: valid_attributes }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
