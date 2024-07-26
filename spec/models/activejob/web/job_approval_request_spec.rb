# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::JobApprovalRequest, type: :model do
  include_context 'common setup'

  let(:approver) { create(:approver) }
  let(:approver_one) { create(:approver_one) }
  let(:executor) { create(:executor) }
  let(:job) { create(:job, minimum_approvals_required: 2, approvers: [approver, approver_one], executors: [executor]) }

  let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: executor.id) }
  let!(:first_job_approval_request) { job_execution.job_approval_requests.first }
  let!(:second_job_approval_request) { job_execution.job_approval_requests.second }

  describe 'validations' do
    it 'is valid' do
      expect(first_job_approval_request).to be_valid
      expect(second_job_approval_request).to be_valid
    end

    it 'is not valid without job_execution_id' do
      first_job_approval_request.job_execution_id = nil
      expect(first_job_approval_request).to_not be_valid
      expect(first_job_approval_request.errors[:job_execution]).to include('must exist')
    end

    it 'is not valid without approver_id' do
      first_job_approval_request.approver_id = nil
      expect(first_job_approval_request).to_not be_valid
      expect(first_job_approval_request.errors[:approver]).to include('must exist')
    end

    it 'is not valid with response after created' do
      expect(first_job_approval_request.response).to eq(nil)
    end
  end

  describe 'callbacks' do
    it "Job Execution status should be 'requested' until reach minimum approvals" do
      first_job_approval_request.update(response: 'approved')
      expect(first_job_approval_request.response).to eq('approved')
      expect(job_execution.status).to eq('requested')
    end

    it "Job Execution status should be 'approved' if reached minimum approvals" do
      first_job_approval_request.update(response: 'approved')
      second_job_approval_request.update(response: 'approved')
      expect(first_job_approval_request.response).to eq('approved')
      expect(second_job_approval_request.response).to eq('approved')
      expect(job_execution.status).to eq('approved')
    end

    it "Job Execution status should be 'rejected' if reached possibilities and rejected" do
      first_job_approval_request.update(response: 'rejected')
      expect(first_job_approval_request.response).to eq('rejected')
      expect(job_execution.status).to eq('rejected')

      # To check job execution status return to 'requested'
      first_job_approval_request.update(response: 'approved')
      expect(first_job_approval_request.response).to eq('approved')
      expect(job_execution.status).to eq('requested')
    end
  end

  describe 'associations' do
    it 'belongs to approver' do
      expect([approver.id, approver_one.id]).to include(first_job_approval_request.approver.id)
    end

    it 'belongs to job_execution' do
      expect(first_job_approval_request.job_execution).to eq(job_execution)
    end
  end

  describe 'Scopes' do
    it '.approved_requests' do
      first_job_approval_request.update(response: 'approved')
      expect(Activejob::Web::JobApprovalRequest.approved_requests).to include(first_job_approval_request)
    end

    it '.rejected_requests' do
      first_job_approval_request.update(response: 'rejected')
      expect(Activejob::Web::JobApprovalRequest.rejected_requests).to include(first_job_approval_request)
    end

    it '.pending_requests for admins' do
      expect(Activejob::Web::JobApprovalRequest.pending_requests(true, nil).count).to eq(2)
    end

    it '.pending_requests for approvers' do
      expect(Activejob::Web::JobApprovalRequest.pending_requests(false, approver.id).count).to eq(1)
    end
  end

  describe 'instance methods' do
    it 'job' do
      expect(first_job_approval_request.job).to eq(job)
    end
  end
end
