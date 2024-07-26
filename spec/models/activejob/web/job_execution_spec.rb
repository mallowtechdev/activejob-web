# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::JobExecution, type: :model do
  include_context 'common setup'

  let(:approver) { create(:approver) }
  let(:approver_one) { create(:approver_one) }
  let(:executor) { create(:executor) }

  let(:job) { create(:job, minimum_approvals_required: 2, approvers: [approver, approver_one], executors: [executor]) }
  let(:job_two) { create(:job_two, minimum_approvals_required: 2) }

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

    describe '#execute' do
      context 'when job execution is approved' do
        before do
          job_execution.update(status: 'approved')
        end

        it 'updates the status to executed' do
          allow(job_execution).to receive(:initiate_job_execution)
          allow(job_execution).to receive(:update_execution_history)

          job_execution.execute
          expect(job_execution.status).to eq('executed')
        end

        it 'updates execution history' do
          expect(job_execution).to receive(:initiate_job_execution)

          job_execution.execute
          expect(job_execution.current_execution_history.details['status']).to eq('executed')
        end

        it 'rescues error and updates execution' do
          job_execution.execute
          expect(job_execution.status).to eq('failed')
          expect(job_execution.current_execution_history.details['status']).to eq('failed')
        end
      end

      context 'when job execution is not approved' do
        before do
          job_execution.update(status: 'requested')
        end

        it 'does not change the status and does not initiate job execution or update history' do
          expect(job_execution).not_to receive(:initiate_job_execution)
          expect(job_execution).not_to receive(:update_execution_history)

          job_execution.execute

          expect(job_execution.status).not_to eq('executed')
          expect(job_execution.status).not_to eq('failed')
        end
      end
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

    it 'should change to executed state' do
      job_execution.update(status: 'approved')
      allow(job_execution).to receive(:initiate_job_execution).and_return(true)
      allow(job_execution).to receive(:update_execution_history).and_return(true)
      job_execution.execute
      expect(job_execution.status).to eq('executed')
    end

    it 'should rescue error with invalid job' do
      job_execution.update(status: 'approved')
      allow(job_execution).to receive(:update_execution_history).and_return(true)
      job_execution.execute
      expect(job_execution.status).to eq('failed')
      expect(job_execution.reason_for_failure).to be_present
    end

    it 'should schedule with valid job' do
      job.update(job_name: 'JobOne')
      job_execution.update(status: 'approved')
      allow(job_execution).to receive(:update_execution_history).and_return(true)
      job_execution.execute
      expect(job_execution.active_job_id).to be_present
      expect(job_execution.reason_for_failure).to eq(nil)
    end

    it 'should update history after executed' do
      job.update(job_name: 'JobOne')
      job_execution.update(status: 'approved')
      expect(job_execution.current_execution_history.details['status']).to eq('requested')
      job_execution.execute
      expect(job_execution.current_execution_history.details['status']).to eq('executed')
    end
  end

  describe 'class methods' do
    it 'update_job_execution_status' do
      expect(Activejob::Web::JobExecution).to respond_to(:update_job_execution_status)
    end
  end

  describe 'attachments' do
    let(:job_execution_with_attachment) { build(:job_execution_with_attachment) }
    it 'should be valid template_file' do
      attachment = job_execution_with_attachment.input_file.attachment
      expect(attachment).to be_present
      expect(attachment.filename.to_s).to eq('lorem_ipsum.jpg')
      expect(attachment.content_type.to_s).to eq('image/jpeg')
    end
  end
end
