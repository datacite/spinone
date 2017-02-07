Rails.application.routes.draw do
  root :to => 'docs#index'

  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :heartbeat, only: [:index]

  scope module: :api, defaults: { format: "json" } do
    concern :workable do
      resources :works
    end

    resources :callbacks, only: [:create]
    resources :contributors, only: [:show, :index], constraints: { :id => /.+/ } do
      resources :contributions, only: [:index]
    end
    resources :data_centers, only: [:show, :index], constraints: { :id => /.+/ }, concerns: :workable, path: "/data-centers"
    resources :datasets, only: [:show, :index], constraints: { :id => /.+/ }, path: "/dats"
    resources :docs, only: [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
    resources :members, only: [:show, :index], concerns: :workable
    resources :pages, only: [:show, :index], constraints: { :id => /.+/ }
    resources :people, only: [:show, :index], constraints: { :id => /.+/ } do
      resources :contributions, only: [:index]
    end
    resources :works, only: [:show, :index], constraints: { :id => /.+/ }
  end
end
