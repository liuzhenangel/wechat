require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do

  # writer your routes here

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  if ENV['USER_TEST_DEBUG'].present?
    get '/test' => 'visitors#test'
    get '/test_for_new_user' => 'visitors#test_for_new_user'
    get '/test_for/:id' => 'visitors#test_for'
  end

  mount Sidekiq::Web => '/sidekiq'
  mount StatusPage::Engine => '/'
  #mount ActionCable.server => '/cable'
  root to: 'visitors#index'
end
