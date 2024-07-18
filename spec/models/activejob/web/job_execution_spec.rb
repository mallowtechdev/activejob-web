# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::JobExecution, type: :model do
  let(:job) { create(:job, minimum_approvals_required: 2) }
  let(:job_two) { create(:job, minimum_approvals_required: 2) }
  let(:approver) { create(:approver) }
  let(:approver_one) { create(:approver_one) }
  let(:executor) { create(:executor) }

  before do
    job.approver_ids = [approver.id, approver_one.id]
    job.executor_ids = [executor.id]
    job.save
  end

  let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: executor.id) }
  describe 'validations' do
    it 'is valid' do
      expect(job_execution).to be_valid
    end

    it 'is not valid with insufficient approvers' do
      job_execution_two = build(:job_execution, job_id: job_two.id, requestor_id: executor.id)
      expect(job_execution_two).to_not be_valid
      expect(job_execution_two.errors[:base]).to include('Minimum Job Approver required is 2')
    end

    it 'is not valid when regex mismatch' do
      job_execution.arguments = { sample_number: 'abc' }
      expect(job_execution).to_not be_valid
      expect(job_execution.errors[:base]).to include("Input argument sample_number does not match regex 'String Regex'")
    end

    it 'is not valid without requestor command' do
      job_execution.requestor_comments = nil
      expect(job_execution).to_not be_valid
      expect(job_execution.errors[:requestor_comments]).to include("can't be blank")
    end

    it 'is not valid without executor(requestor)' do
      job_execution.requestor_id = nil
      expect(job_execution).to_not be_valid
      expect(job_execution.errors[:executor].first).to include("can't be blank")
    end
  end

  describe 'callbacks' do
    it 'sets default value for status' do
      job_execution_two = build(:job_execution, job_id: job_two.id, requestor_id: executor.id)
      expect(job_execution_two.status).to eq('requested')
    end

    it 'creates initial execution history' do
      expect(job_execution.job_execution_histories.count).to eq(1)
    end

    it 'sets initial execution history is current execution' do
      expect(job_execution.job_execution_histories.first.is_current).to be_truthy
    end


    it 'creates job approval requests' do
      expect(job_execution.job_approval_requests.count).to eq(job.minimum_approvals_required)
    end
  end

  describe 'Scopes' do
    it '.requested' do
      expect(Activejob::Web::JobExecution.requested).to include(job_execution)
    end
  end

  describe 'associations' do
    it 'belongs to job' do
      expect(job_execution.job).to eq(job)
    end

    it 'belongs to executor' do
      expect(job_execution.executor.id).to eq(executor.id)
    end

    it 'has one attached input_file' do
      expect(job_execution).to respond_to(:input_file)
    end

    it 'has_many job_approval_requests' do
      expect(job_execution.job_approval_requests.count).to eq(2)
    end

    it 'has_many job_execution_histories' do
      expect(job_execution.job_approval_requests.count.present?).to be_truthy
    end
  end

  describe 'instance methods' do
    it 'create_execution_history' do
      expect(job_execution).to respond_to(:create_execution_history)
    end

    it 'update_execution_history' do
      expect(job_execution).to respond_to(:update_execution_history)
    end

    it 'remove_create_approvals' do
      expect(job_execution).to respond_to(:remove_create_approvals)
    end

    it 'gen_reqs_and_histories' do
      expect(job_execution).to respond_to(:gen_reqs_and_histories)
    end

    it 'execute' do
      expect(job_execution).to respond_to(:execute)
    end

    it 'current_execution_history' do
      expect(job_execution.job_execution_histories.first.id).to eq(job_execution.current_execution_history.id)
    end

    it 'should return true for cancel_execution' do
      expect(job_execution.cancel_execution).to be_truthy
    end

    it 'should return true for requested?' do
      expect(job_execution.requested?).to be_truthy
    end

    it 'should return false for approved?' do
      expect(job_execution.approved?).to be_falsey
    end

    it 'should return false for cancelled?' do
      expect(job_execution.cancelled?).to be_falsey
    end

    it 'should return false for executed?' do
      expect(job_execution.executed?).to be_falsey
    end

    it 'should return false for live_log?' do
      expect(job_execution.live_log?).to be_falsey
    end
  end

  describe 'class methods' do

    it 'update_job_execution_status' do
      expect(Activejob::Web::JobExecution).to respond_to(:update_job_execution_status)
    end

  end
end
