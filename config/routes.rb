# frozen_string_literal: true

Rails.application.routes.draw do
  root 'activejob_web/jobs#index'

  namespace :activejob_web do
    resources :jobs, only: %i[index show update]
  end

  if Rails.application.config.enable_custom_routes == true
    get 'activejob_web/jobs/:id/edit', to: 'activejob_web/jobs#edit',
                                       constraints: UserRoleConstraint.new(Activejob::Web.job_approvers_class.constantize.allow_admin_access?),
                                       as: 'edit_activejob_web_job'
  else
    get 'activejob_web/jobs/:id/edit', to: 'activejob_web/jobs#edit', as: 'edit_activejob_web_job'
  end
end
