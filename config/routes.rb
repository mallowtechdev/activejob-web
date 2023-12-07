# frozen_string_literal: true

Rails.application.routes.draw do
  root 'activejob_web/jobs#index'

  namespace :activejob_web do
    resources :jobs, only: %i[index show update] do
      resources :job_executions do
        resources :job_approval_requests do
          member do
            get :action
          end
        end
        member do
          patch :cancel
          post :reinitiate
        end
      end
      member do
        get :download_pdf
      end
    end
  end
  if Rails.application.config.enable_custom_routes == true
    get 'activejob_web/jobs/:id/edit', to: 'activejob_web/jobs#edit',
                                       constraints: UserRoleConstraint.new(Activejob::Web.job_approvers_class.constantize.allow_admin_access?),
                                       as: 'edit_activejob_web_job'
  else
    get 'activejob_web/jobs/:id/edit', to: 'activejob_web/jobs#edit', as: 'edit_activejob_web_job'
  end
end
