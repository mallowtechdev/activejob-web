# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivejobWeb::JobsController, type: :request do
  let(:valid_attributes) { { title: 'Activejob', description: 'Web Gem' } }
  let(:job) { create(:job) }
  let!(:user) { create(:user) }
  describe 'GET #edit' do
    context 'valid' do
      it 'valid edit' do
        get edit_activejob_web_job_path(job.id)
        expect(response).to have_http_status 200
      end
    end

    context 'invalid' do
      it 'invalid edit without parameters' do
        expect { get edit_activejob_web_job_path(SecureRandom.uuid) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #update' do
    let(:approver) { create(:approver) }
    let(:executor) { create(:executor) }
    let(:approver1) { create(:approver1) }
    let(:executor1) { create(:executor1) }
    context 'valid' do
      it 'valid update of job with approvers and executors gets assigned' do
        patch activejob_web_job_path(job.id),
              params: { id: job.id, activejob_web_job: valid_attributes.merge(approver_ids: [approver.id], executor_ids: [executor.id]) }
        job.reload
        expect(response).to redirect_to(activejob_web_job_path(job))
        expect(job.approvers).to include(approver)
        expect(job.executors).to include(executor)
      end

      it 'valid update of job with removal of assigned approvers and executors' do
        job1 = ActivejobWeb::Job.create(valid_attributes.merge(approver_ids: [approver1.id, approver.id], executor_ids: [executor1.id, executor.id]))
        expect(job1.approvers).to include(approver1)
        expect(job1.executors).to include(executor1)
        patch activejob_web_job_path(job1),
              params: { id: job1.id, activejob_web_job: valid_attributes.merge(approver_ids: [approver.id], executor_ids: [executor.id]) }
        job1.reload
        expect(response).to redirect_to(activejob_web_job_path(job1))
        expect(job1.approvers).not_to include(approver1)
        expect(job1.executors).not_to include(executor1)
      end
    end

    context 'invalid' do
      it 'should not update job with invalid approvers and executors' do
        expect do
          patch activejob_web_job_path(job.id),
                params: { id: job.id, activejob_web_job: valid_attributes.merge(approver_ids: ['4'], executor_ids: ['Test']) }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
