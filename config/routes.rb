require 'resque_web'

TollMaster::Application.routes.draw do

  # Logins and Profiles
  devise_for :users, skip: [:registration]
  get '/rails_admin/users/sign_in' => redirect('/users/sign_in')
  get '/sidekiq/users/sign_in' => redirect('/users/sign_in')
  
  resources :users, path: 'profiles', except: [:new, :create, :edit, :show, :destroy, :update] do
    collection do
      post '/update' => :update
    end
  end

  root to: 'user_entry#show' # Change this to something else in your app.

  resource :user_entry, controller: :user_entry, except: [:new, :create, :edit, :update, :show, :destroy] do
    member do
      get :resend_sms
      post :send_first_sms
      post :authenticate
    end
  end
  
  # The rest of the routes file is specific to this app and you will have to manipulate it for your app. The 
  # 404 catchall route below always has to be at the end, if you intend to use it as designed in this app.

  # Admin - these routes sould ideally be protected with a constraint
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq_ui'
    # Adds RailsAdmin
    mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'
  end

  get '/dash/:link_secret' => 'dashboard#dash', as: :dash
  post '/dash/open' => 'dashboard#open_sesame'
  post '/dash/checkout' => 'dashboard#checkout'
  post '/dash/checkin' => 'dashboard#checkin'
  
  # Integrations - these are examples of how to integrate various 3rd party APIs.

  # Stripe
  resources :card_records, only: [:create]  
  
  # Need a catch all to redirect to the errors controller, for catching 404s as an exception
  match "*path", to: "errors#catch_404", via: [:get, :post]
end
