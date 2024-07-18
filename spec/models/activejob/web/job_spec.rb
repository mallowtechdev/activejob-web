# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::Job, type: :model do
  let(:job) { create(:job) }
  let(:new_job) { build(:job) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(job).to be_valid
    end

    it 'is not valid without a title' do
      job.title = nil
      expect(job).to_not be_valid
      expect(job.errors[:title]).to include("can't be blank")
    end

    it 'is not valid without a job_name' do
      job.job_name = nil
      expect(job).to_not be_valid
      expect(job.errors[:job_name]).to include("can't be blank")
    end

    it 'is not valid without a description' do
      job.description = nil
      expect(job).to_not be_valid
      expect(job.errors[:description]).to include("can't be blank")
    end

    it 'is not valid with duplicate file arguments' do
      new_job.input_arguments << { 'name' => 'sample file', 'type' => 'File' }
      new_job.input_arguments << { 'name' => 'another sample file', 'type' => 'File' }
      expect(new_job).to_not be_valid
      expect(new_job.errors[:base]).to include("Duplicate 'File' types found.")
    end

    it 'is valid with correct allowed_characters format' do
      new_job.input_arguments = [{ name: 'sample name',
                                   type: 'String',
                                   required: true,
                                   allowed_characters: { 'regex' => /\A\d+\z/, 'description' => 'String Regex' } }]
      expect(new_job).to be_valid
    end

    it 'is not valid with incorrect allowed_characters format' do
      new_job.input_arguments = [{ name: 'sample name',
                                   type: 'String',
                                   required: true,
                                   allowed_characters: { 'description' => 'regex command' } }]
      expect(new_job).to_not be_valid
      expect(new_job.errors[:base]).to include("Invalid 'allowed_characters' input. Format must be { 'regex' => <regex>, 'description' => <description> }")
    end

    it 'is not valid with insufficient approvers' do
      job.minimum_approvals_required = 2
      expect(job).to_not be_valid
      expect(job.errors[:base]).to include('Minimum Approver required is 2. Please select 2 more approver(s).')
    end

    it 'is valid with 0 approvers' do
      job.minimum_approvals_required = 0
      expect(job).to be_valid
    end
  end

  describe 'associations' do
    let(:approver) { create(:approver) }
    let(:approver_one) { create(:approver_one) }
    let(:executor) { create(:executor) }

    before do
      job.approver_ids = [approver.id, approver_one.id]
      job.executor_ids = [executor.id]
    end

    it 'has many approvers' do
      expect(job.approvers.count).to eq(2)
    end

    it 'has many executors' do
      expect(job.executors.count).to eq(1)
    end

    it 'has many job_executions' do
      expect(job).to respond_to(:job_executions)
    end

    it 'has one attached template_file' do
      expect(job).to respond_to(:template_file)
    end
  end

  describe 'callbacks' do
    let(:job_two) { build(:job_two) }
    it 'sets default values for queue, max_run_time, minimum_approvals_required, and priority' do
      expect(job_two.queue).to eq('default')
      expect(job_two.max_run_time).to eq(60)
      expect(job_two.minimum_approvals_required).to eq(0)
      expect(job_two.priority).to eq(1)
    end
  end
end
