# frozen_string_literal: true

Rails.application.routes.draw do
  root 'activejob_web/jobs#index'

  namespace :activejob_web do
    resources :jobs, only: %i[index show update] do
      resources :job_executions do
        resources :job_approval_requests
      end
      member do
        get :download_pdf
      end
    end
  end

  get 'activejob_web/jobs/:id/edit', to: 'activejob_web/jobs#edit',
                                     constraints: UserRoleConstraint.new(Activejob::Web.job_approvers_class.constantize.custom_lambda),
                                     as: 'edit_activejob_web_job'
end
