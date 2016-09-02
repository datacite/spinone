require 'sidekiq/web'

Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/signout', to: 'sessions#destroy'

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root :to => 'index#index'

  resources :agents
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :heartbeat, only: [:index]
  get "/dashboard", to: "status#index"

  scope module: :api, defaults: { format: "json" } do
    concern :workable do
      resources :works
    end

    resources :callbacks, only: [:create]
    resources :contributors, only: [:show, :index], constraints: { :id => /.+/ } do
      resources :contributions, only: [:index]
    end
    resources :contributions, only: [:index]
    resources :datasets, only: [:show, :index], constraints: { :id => /.+/ }, path: "/dats"
    resources :docs, only: [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
    resources :events, only: [:show, :index]
    resources :groups, only: [:show, :index]
    resources :members, only: [:show, :index], concerns: :workable
    resources :pages, only: [:show, :index], constraints: { :id => /.+/ }
    resources :publishers, only: [:show, :index], constraints: { :id => /.+/ }, concerns: :workable
    resources :registration_agencies, only: [:show, :index], path: "/registration-agencies"
    resources :relation_types, only: [:show, :index], path: "/relation-types"
    resources :relations, only: [:index]
    resources :resource_types, only: [:show, :index], path: "/resource-types"
    resources :sources, only: [:show, :index], concerns: :workable
    resources :status, only: [:index]
    resources :work_types, only: [:show, :index], path: "/work-types"
    resources :works, only: [:show, :index], constraints: { :id => /.+/ }
  end
end
