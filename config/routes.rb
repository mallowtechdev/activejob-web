Rails.application.routes.draw do
  # Defines the root path route ("/")
  namespace :activejob_web do
    root 'jobs#index'
    resources :jobs, only: %i[index show]
  end
end
