# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::Admin, type: :model do
  let(:admin) { create(:admin) }

  describe 'Configuration' do
    it 'class name should be match' do
      expect(admin.class.name).to eq(Activejob::Web::Admin.name)
    end

    it 'table name should be match' do
      expect(admin.class.table_name).to eq(Activejob::Web.admins_model.constantize.table_name)
    end
  end

  describe 'validations' do
    let!(:job) { create(:job) }
    let!(:job_two) { create(:job_two) }

    let(:approver) { create(:approver) }
    let(:executor) { create(:executor) }
    let(:job_with_approver) { create(:job, minimum_approvals_required: 1, approvers: [approver], executors: [executor]) }

    let(:job_execution) { create(:job_execution, job_id: job_with_approver.id, requestor_id: executor.id) }
    let(:job_execution_two) { create(:job_execution_two, job_id: job_with_approver.id, requestor_id: executor.id) }

    it 'is valid' do
      expect(admin).to be_valid
    end

    it 'should include UsersConcern' do
      expect(Activejob::Web::Admin.ancestors).to include(Activejob::Web::UsersConcern)
    end

    it 'should be all jobs for admin' do
      expect(admin.jobs.count).to eq(2)
    end

    it 'should be jobs empty for executor/approvers if not assigned' do
      expect(executor.jobs.count).to eq(0)
    end

    it 'should be all job_approval_requests for admin' do
      job_execution
      job_execution_two
      expect(admin.job_approval_requests.count).to eq(2)
    end
  end
end
