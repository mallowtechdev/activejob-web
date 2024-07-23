# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activejob::Web::JobsController, type: :request do
  include_context 'common setup'

  let(:source_admin) { create(:source_admin) }
  let(:admin) { create(:admin) }
  let(:source_approver) { create(:source_approver) }
  let(:approver) { create(:approver) }
  let(:source_executor) { create(:source_executor) }
  let(:executor) { create(:executor) }
  let(:source_common) { create(:source_common) }

  describe 'GET /index' do
    context 'helper validations' do
      it 'redirect to root_path if current_user_helper not set' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:current_user_helper).and_return(:none)
        get activejob_web_jobs_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Please configure the 'current_user_method' in the ActiveJob::Web configuration, or add the helper method 'activejob_web_user' to the ApplicationHelper.")
      end

      it 'redirect to root_path if user not set' do
        get activejob_web_jobs_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('User not found or invalid.')
      end
    end

    context 'helper validation for Admin' do
      it 'should not redirect to root_path if user set' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
        get activejob_web_jobs_path
      end

      it 'should valid user' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
        get activejob_web_jobs_path
        expect(flash[:alert]).to_not eq('User not found or invalid.')
      end

      it 'should match with host model' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
        get activejob_web_jobs_path
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Admin')
      end
    end

    context 'helper validation for Common' do
      it 'should approver match with host model' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get activejob_web_jobs_path
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Common')
      end

      it 'should executor match with host model' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get activejob_web_jobs_path
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Common')
      end
    end

    context 'helper validation for Approver' do
      before do
        approver_config
      end
      it 'should approver match with host model' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get activejob_web_jobs_path
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Approver')
      end
    end

    context 'helper validation for executor' do
      before do
        executor_config
      end
      it 'should executor match with host model' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get activejob_web_jobs_path
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Executor')
      end
    end

    context 'GET Admin /index' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
      end

      it 'returns a successful response' do
        get activejob_web_jobs_path
        expect(response).to have_http_status 200
        expect(response).not_to render_template(partial: '_common_user_index')
      end

      it 'should not be @jobs empty' do
        job = create(:job)
        get activejob_web_jobs_path
        expect(assigns(:jobs)).to eq([job])
      end
    end

    context 'GET Approver /index' do
      before do
        approver_config
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      end

      it 'returns a successful response' do
        get activejob_web_jobs_path
        expect(response).to have_http_status 200
      end

      it 'should not be @jobs empty' do
        job = create(:job, minimum_approvals_required: 1)
        job.approver_ids = [source_approver.id]
        job.save
        get activejob_web_jobs_path
        expect(assigns(:jobs)).to eq([job])
      end

      it 'should be empty @jobs' do
        create(:job, minimum_approvals_required: 0, executors: [executor])
        get activejob_web_jobs_path
        expect(assigns(:jobs)).to eq([])
      end
    end

    context 'GET Executor /index' do
      before do
        executor_config
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      end

      it 'returns a successful response' do
        get activejob_web_jobs_path
        expect(response).to have_http_status 200
      end

      it 'should be @jobs empty' do
        create(:job, minimum_approvals_required: 1, approvers: [approver])
        get activejob_web_jobs_path
        expect(assigns(:jobs)).to eq([])
      end

      it 'should not be empty @jobs' do
        job = create(:job, minimum_approvals_required: 0)
        job.executor_ids = [source_executor.id]
        job.save
        get activejob_web_jobs_path
        expect(assigns(:jobs)).to eq([job])
      end
    end

    context 'GET Common /index' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_common)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      end

      it 'returns a successful response' do
        get activejob_web_jobs_path
        expect(response).to have_http_status 200
        expect(response).to render_template(partial: '_common_user_index')
      end

      it 'should be @jobs empty' do
        job_one = create(:job, minimum_approvals_required: 1)
        job_one.approver_ids = [source_common.id]
        job_one.save
        job_two = create(:job_two, minimum_approvals_required: 1)
        job_two.executor_ids = [source_common.id]
        job_two.save
        get activejob_web_jobs_path
        expect(assigns(:approval_jobs)).to eq([job_one])
        expect(assigns(:execution_jobs)).to eq([job_two])
      end
    end
  end

  describe 'GET #show' do
    let(:source_user) { create(:source_user) }
    let(:job) { create(:job) }
    context 'returns a successful response' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_user)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
      end
      it 'Valid show' do
        get activejob_web_job_path(job.id)
        expect(response).to render_template('show')
        expect(response).to have_http_status 200
      end
    end
  end

  describe 'GET #edit' do
    let(:source_user) { create(:source_user) }
    let(:job) { create(:job) }
    before do
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_user)
    end
    it 'valid edit' do
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
      get edit_activejob_web_job_path(job.id)
      expect(response).to have_http_status 200
    end

    it 'not valid edit' do
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      get edit_activejob_web_job_path(job.id)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You are not authorized to perform this action')
    end
  end

  describe 'PATCH #update' do
    let(:source_user) { create(:source_user) }
    let(:job) { create(:job, minimum_approvals_required: 1) }
    before do
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_user)
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
    end

    it 'valid' do
      patch activejob_web_job_path(job.id),
            params: { id: job.id, activejob_web_job: { approver_ids: [approver.id], executor_ids: [executor.id] } }
      expect(response).to redirect_to(activejob_web_job_path(job.id))
      expect(flash[:notice]).to eq('Job was successfully updated.')
    end

    it 'invalid' do
      job = create(:job, minimum_approvals_required: 2)
      patch activejob_web_job_path(job.id),
            params: { id: job.id, activejob_web_job: { approver_ids: [approver.id], executor_ids: [executor.id] } }

      expect(response).to render_template(:edit)
    end
  end
end
