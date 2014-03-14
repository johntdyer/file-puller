FilePuller::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'


  #get "requests/index"
  #resources :requests
  resources :requests do
     member do
       get :download
     end
   end

  get "requests/download_log"
  #get "home/download_log"

  root :to => 'requests#index'
  #match "requests/new" => "requests#new", via: [:get, :post]


end
