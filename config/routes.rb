Rails.application.routes.draw do
  root :to => 'index#index'

  resources :index, only: [:index]
  resources :heartbeat, only: [:index]

  scope module: :api, defaults: { format: "json" } do
    concern :workable do
      resources :works
    end

    resources :data_centers, only: [:show, :index], constraints: { :id => /.+/ }, concerns: :workable, path: "/data-centers"
    resources :datasets, only: [:show, :index], constraints: { :id => /.+/ }, path: "/dats"
    resources :members, only: [:show, :index], concerns: :workable
    resources :milestones, only: [:show, :index]
    resources :pages, only: [:show, :index], constraints: { :id => /.+/ }
    resources :prefixes, only: [:show], constraints: { :id => /.+/ }
    resources :user_stories, only: [:show, :index], path: "/user-stories"
    resources :works, only: [:show, :index], constraints: { :id => /.+/ }
  end

  # rescue routing errors
  match "*path", to: "index#routing_error", via: :all
end
