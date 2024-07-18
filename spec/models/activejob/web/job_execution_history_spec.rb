require 'rails_helper'

RSpec.describe Activejob::Web::JobExecutionHistory, type: :model do
  let(:job) { create(:job) }
  let(:executor) { create(:executor) }
  before do
    job.executor_ids = [executor.id]
    job.save
  end

  let(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: executor.id) }
  let(:job_execution_history) { job_execution.job_execution_histories.first }

  describe 'validations' do
    it 'is valid' do
      expect(job_execution_history).to be_valid
    end

    it 'is not valid without job_execution_id' do
      job_execution_history.job_execution_id = nil
      expect(job_execution_history).to_not be_valid
      expect(job_execution_history.errors[:job_execution]).to include('must exist')
    end

    it 'is not valid without job_id' do
      job_execution_history.job_id = nil
      expect(job_execution_history).to_not be_valid
      expect(job_execution_history.errors[:job]).to include('must exist')
    end

    it 'is not valid without details' do
      job_execution_history.details = nil
      expect(job_execution_history).to_not be_valid
      expect(job_execution_history.errors[:details]).to include("can't be blank")
    end

    it 'is not valid without arguments' do
      job_execution_history.arguments = nil
      expect(job_execution_history).to_not be_valid
      expect(job_execution_history.errors[:arguments]).to include("can't be blank")
    end

    it 'should be one current execution' do
      expect(job_execution.job_execution_histories.where(is_current: true).count).to eq(1)
    end

    it 'current history arguments should match with job execution arguments' do
      expect(job_execution_history.arguments).to eq(job_execution.arguments)
    end
  end

  describe 'instance methods' do
    it 'current_history?' do
      expect(job_execution_history).to respond_to(:current_history?)
    end

    it 'log_events' do
      expect(job_execution_history).to respond_to(:log_events)
    end
  end
end
