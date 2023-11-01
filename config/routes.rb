Rails.application.routes.draw do
  resources :activejob_web_jobs do
    member do
      get :download_pdf
    end
  end

end
