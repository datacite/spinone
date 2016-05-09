require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'users/sessions#new', :as => :new_session
    post 'sign_in', :to => 'users/session#create', :as => :session
    get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
  end

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root :to => 'index#index'

  resources :agents
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :status, :only => [:index]

  get "/api", to: "api/index#index"

  namespace :api, defaults: { format: "json" } do
    scope module: :v1, constraints: ApiConstraint.new(version: 1, default: :true) do
      resources :callbacks, only: [:create]
      resources :relation_types, only: [:show, :index]
      resources :status, only: [:index]
    end
  end
end
