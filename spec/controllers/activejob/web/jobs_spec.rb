require 'rails_helper'

RSpec.describe Activejob::Web::JobsController, type: :controller do
  include_context 'common setup'

  let(:source_admin) { create(:source_admin) }
  let(:admin) { create(:admin) }
  let(:source_approver) { create(:source_approver) }
  let(:approver) { create(:approver) }
  let(:source_executor) { create(:source_executor) }
  let(:executor) { create(:executor) }
  let(:source_common) { create(:source_common) }

  describe 'GET #index' do
    context 'when current_user_helper configuration' do
      context 'is not set' do
        it 'redirects to root_path with an alert' do
          allow_any_instance_of(Activejob::Web::Authentication).to receive(:current_user_helper).and_return(:none)
          get :index
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq("Please configure the 'current_user_method' in the ActiveJob::Web configuration, or add the helper method 'activejob_web_user' to the ApplicationHelper.")
        end
      end

      context 'is set and when user' do
        context 'is not set' do
          it 'redirects to root_path with an alert' do
            get :index
            expect(response).to redirect_to(root_path)
            expect(flash[:alert]).to eq('User not found or invalid.')
          end
        end

        context 'is set' do
          before do
            allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
            allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
          end

          it 'renders the index template' do
            get :index
            expect(response).not_to redirect_to(root_path)
            expect(flash[:alert]).to eq(nil)
          end
        end
      end
    end

    context 'when user is an admin' do
      it 'assign the Admin user class' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Admin')
      end
    end

    context 'when user is a Common user' do
      it 'assigns the Common user class' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Common')
      end

      it 'assigns the Common user class for Executor' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Common')
      end
    end

    context 'when user is an Approver' do
      before { approver_config }

      it 'assigns the Approver class' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Approver')
      end
    end

    context 'when user is an Executor' do
      before { executor_config }

      it 'assigns the Executor class' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get :index
        expect(response).to render_template(:index)
        expect(assigns(:activejob_web_current_user).class.name).to eq('Activejob::Web::Executor')
      end
    end

    context 'when user is an Admin' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_admin)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns jobs to @jobs' do
        job = create(:job)
        get :index
        expect(assigns(:jobs)).to eq([job])
      end
    end

    context 'when user is an Approver' do
      before do
        approver_config
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_approver)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      end

      it 'renders' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns jobs to @jobs' do
        job = create(:job, minimum_approvals_required: 1)
        job.approver_ids = [source_approver.id]
        job.save
        get :index
        expect(assigns(:jobs)).to eq([job])
      end

      it 'assigns no jobs to @jobs' do
        create(:job, minimum_approvals_required: 0, executors: [executor])
        get :index
        expect(assigns(:jobs)).to be_empty
      end
    end

    context 'when user is an Executor' do
      before do
        executor_config
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_executor)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)

      end

      it 'assigns no jobs to @jobs' do
        create(:job, minimum_approvals_required: 1, approvers: [approver])
        get :index
        expect(assigns(:jobs)).to be_empty
      end

      it 'assigns jobs to @jobs' do
        job = create(:job, minimum_approvals_required: 0)
        job.executor_ids = [source_executor.id]
        job.save
        get :index
        expect(assigns(:jobs)).to eq([job])
      end
    end

    context 'when user is a Common user' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_common)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns jobs to @approval_jobs and @execution_jobs' do
        job_one = create(:job, minimum_approvals_required: 1)
        job_one.approver_ids = [source_common.id]
        job_one.save
        job_two = create(:job_two, minimum_approvals_required: 1)
        job_two.executor_ids = [source_common.id]
        job_two.save
        get :index
        expect(assigns(:approval_jobs)).to eq([job_one])
        expect(assigns(:execution_jobs)).to eq([job_two])
      end
    end
  end

  describe 'GET #show' do
    let(:source_user) { create(:source_user) }
    let(:job) { create(:job) }

    context 'when user is an admin' do
      before do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_user)
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
      end

      it 'renders the show template' do
        get :show, params: { id: job.id }
        expect(response).to render_template(:show)
        expect(assigns(:job)).to eq(job)
      end
    end
  end

  describe 'GET #edit' do
    let(:source_user) { create(:source_user) }
    let(:job) { create(:job) }
    before do
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_user)
    end

    context 'when user is an admin' do
      it 'renders the edit template' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
        get :edit, params: { id: job.id }
        expect(response).to render_template(:edit)
        expect(assigns(:job)).to eq(job)
      end
    end

    context 'when user is not an admin' do
      it 'redirects to root_path with an alert' do
        allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(false)
        get :edit, params: { id: job.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe 'PATCH #update' do
    let(:source_user) { create(:source_user) }
    let(:job) { create(:job, minimum_approvals_required: 1) }
    before do
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:fetch_host_user).and_return(source_user)
      allow_any_instance_of(Activejob::Web::Authentication).to receive(:admin?).and_return(true)
    end

    context 'when update is successful' do
      it 'redirects to the job show page' do
        patch :update, params: { id: job.id, activejob_web_job: { approver_ids: [approver.id], executor_ids: [executor.id] } }
        expect(response).to redirect_to(activejob_web_job_path(job.id))
        expect(flash[:notice]).to eq('Job was successfully updated.')
      end
    end

    context 'when update is unsuccessful' do
      it 'renders the edit template' do
        job = create(:job, minimum_approvals_required: 2)
        patch :update, params: { id: job.id, activejob_web_job: { approver_ids: [approver.id], executor_ids: [executor.id] } }
        expect(response).to render_template(:edit)
      end
    end
  end
end
