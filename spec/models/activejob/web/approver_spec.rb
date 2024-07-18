# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::Approver, type: :model do
  let(:approver) { create(:approver) }

  describe 'Configuration' do
    it 'class name should be match' do
      expect(approver.class.name).to eq(Activejob::Web::Approver.name)
    end

    it 'table name should be match' do
      expect(approver.class.table_name).to eq(Activejob::Web.approvers_model.constantize.table_name)
    end
  end

  describe 'validations' do
    let(:approver) { create(:approver) }
    let(:executor) { create(:executor) }
    let!(:job_with_approver) { create(:job, minimum_approvals_required: 1, approvers: [approver], executors: [executor]) }

    let!(:job_execution) { create(:job_execution, job_id: job_with_approver.id, requestor_id: executor.id) }
    let(:job_execution_two) { create(:job_execution_two, job_id: job_with_approver.id, requestor_id: executor.id) }

    it 'is valid' do
      expect(approver).to be_valid
    end

    it 'is not valid' do
      approver.id = nil
      expect(approver).to be_valid
    end

    it 'should include UsersConcern' do
      expect(Activejob::Web::Approver.ancestors).to include(Activejob::Web::UsersConcern)
    end

    it 'should not be jobs empty' do
      expect(approver.jobs.count).to eq(1)
    end

    it 'should be one job_approval_request' do
      expect(approver.job_approval_requests.count).to eq(1)
    end

    it 'should be two job_approval_requests' do
      job_execution_two
      expect(approver.job_approval_requests.count).to eq(2)
    end
  end
end
