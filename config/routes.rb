# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :activejob do
    namespace :web do
      resources :jobs, only: %i[index show create update edit new] do
        collection do
          get 'load_more_users', to: 'jobs#load_more_users'
        end
        resources :job_executions do
          member do
            patch :cancel
            post :reinitiate
            get :execute
            get :logs
            get :history
            get :live_logs
            get :local_logs
          end
        end
        member do
          get :download_pdf
        end
        resources :job_approval_requests do
          member do
            get :action
          end
        end
      end
    end
  end
end
