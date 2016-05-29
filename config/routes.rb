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
  get "/dashboard", to: "status#index"
  get "/api", to: "api/index#index"

  scope module: :api, defaults: { format: "json" } do
    resources :callbacks, only: [:create]
    resources :contributors, only: [:show, :index], constraints: { :id => /.+/ }
    resources :contributions, only: [:index]
    resources :events, only: [:show, :index]
    resources :groups, only: [:show, :index]
    resources :members, only: [:show, :index]
    resources :publishers, only: [:show, :index], constraints: { :id => /.+/ }
    resources :registration_agencies, only: [:show, :index], path: "/registration-agencies"
    resources :relation_types, only: [:show, :index], path: "/relation-types"
    resources :relations, only: [:index]
    resources :resource_types, only: [:show, :index], path: "/resource-types"
    resources :sources, only: [:show, :index]
    resources :status, only: [:index]
    resources :work_types, only: [:show, :index], path: "/work-types"
    resources :works, only: [:show, :index], constraints: { :id => /.+/ }
  end
end
