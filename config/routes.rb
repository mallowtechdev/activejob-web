# frozen_string_literal: true

Rails.application.routes.draw do
  root 'activejob_web/jobs#index'
  namespace :activejob_web do
    resources :jobs, only: %i[index show edit update]
  end
end
