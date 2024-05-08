# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :activejob do
    namespace :web do
      resources :jobs, only: %i[index show update edit] do
        resources :job_executions do
          member do
            patch :cancel
            post :reinitiate
            get :execute
            get :logs
            get :history
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
