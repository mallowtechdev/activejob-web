Rails.application.routes.draw do
  namespace :activejob_web do
    root 'jobs#index'
    resources :jobs do
    member do
      get :download_pdf
    end
    end
  end

end
