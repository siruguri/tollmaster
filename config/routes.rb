require 'resque_web'

TollMaster::Application.routes.draw do

  # Logins and Profiles
  devise_for :users
  resources :users, path: 'profiles'

  root to: 'user_entry#show' # Change this to something else in your app.
  post '/user_entry' => "user_entry#authenticate"
  get '/user_entry/resend_sms' => "user_entry#resend_sms"
  
  # The rest of the routes file is specific to this app and you will have to manipulate it for your app. The 
  # 404 catchall route below always has to be at the end, if you intend to use it as designed in this app.

  # Admin - these routes sould ideally be protected with a constraint
  require 'sidekiq/web'
  # authenticate :admin, lambda { |u| u.is_a? Admin } do
  mount Sidekiq::Web => '/sidekiq_ui'
  # Adds RailsAdmin
  mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'

  #end

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
