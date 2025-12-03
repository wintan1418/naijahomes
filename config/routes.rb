Rails.application.routes.draw do
  devise_for :users
  
  root "home#index"
  get "properties", to: "properties#index", as: :properties
  
  resource :profile, only: [:show]
  
  resources :properties do
    resources :leads, only: [:create]
    resources :favourites, only: [:create] do
      collection do
        delete :destroy
      end
    end
  end
  
  namespace :landlord do
    root "dashboard#index"
    resources :properties
    resources :leads do
      member do
        patch :advance_status
        patch :mark_as_lost
      end
      collection do
        get :analytics
      end
      resources :lead_notes, only: [:create], path: 'notes'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
