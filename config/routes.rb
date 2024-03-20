Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Devise engine routes
  devise_for :users

  # Swagger routes
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Defines the root path route ("/")
  root "home#show"

  # ---------- Namespace: Administration
  namespace :administration do
    get 'users',           to: "/administration/users#index"
    get 'data_imports',    to: "/administration/data_imports#new"

    resources :users do
      member do
        patch :set_playground
        post :activate
      end
    end

    resources :groups do
      member do
        post :activate
      end
    end

    resources :parameters_lists do
      resources :parameters
      resources :parameters_imports, :only=>[:new, :create]
        member do
          post :activate
        end
    end

    resources :parameters

    resources :data_imports
  end  
end
