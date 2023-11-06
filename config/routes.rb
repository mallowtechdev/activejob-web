# frozen_string_literal: true

Rails.application.routes.draw do
  root 'activejob_web/jobs#index'
  namespace :activejob_web do
    resources :jobs, only: %i[index show edit update]
    # if Rails.application.config.enable_custom_routes
    #   # Define a custom lambda function for route matching
    #   custom_lambda = lambda do |_request|
    #     job = ActivejobWeb::Job.first
    #     job.id == '95ee9435-2b03-42aa-8132-2716a019e51f'
    #   end
    #   # get 'jobs/:id/edit', to: 'jobs#edit', constraints: UserRoleConstraint.new(custom_lambda)
    #   get 'jobs/:id/edit', to: 'jobs#edit', constraints: custom_lambda
    # else
    #   get 'jobs/:id/edit', to: 'jobs#edit'
    # end
  end
end
