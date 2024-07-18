# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::Executor, type: :model do
  let(:executor) { create(:executor) }

  describe 'Configurations' do
    it 'class name should be match' do
      expect(executor.class.name).to eq(Activejob::Web::Executor.name)
    end

    it 'table name should be match' do
      expect(executor.class.table_name).to eq(Activejob::Web.executors_model.constantize.table_name)
    end
  end

  describe 'validations' do
    let(:approver) { create(:approver) }
    let(:executor) { create(:executor) }
    let!(:job) { create(:job, minimum_approvals_required: 1, approvers: [approver], executors: [executor]) }
    let!(:job_execution) { create(:job_execution, job_id: job.id, requestor_id: executor.id) }
    let(:job_execution_two) { create(:job_execution_two, job_id: job.id, requestor_id: executor.id) }

    it 'is valid' do
      expect(executor).to be_valid
    end

    it 'is not valid' do
      executor.id = nil
      expect(executor).to be_valid
    end

    it 'should include UsersConcern' do
      expect(Activejob::Web::Executor.ancestors).to include(Activejob::Web::UsersConcern)
    end

    it 'should not be jobs empty' do
      expect(executor.jobs.count).to eq(1)
    end

    it 'should be one job_execution' do
      expect(executor.job_executions.count).to eq(1)
    end

    it 'should be two job_executions' do
      job_execution_two
      expect(executor.job_executions.count).to eq(2)
    end
  end
end
