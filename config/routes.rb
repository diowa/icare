Icare::Application.routes.draw do

  root to: 'pages#home'

  resources :conversations, only: [:show, :new, :create, :update, :index] do
    get :unread, on: :collection
    resources :messages, only: [:create]
  end

  resources :feedbacks, only: [:show, :new, :create, :edit, :update, :destroy, :index]

  resources :itineraries, only: [:show, :new, :create, :edit, :update, :destroy, :index, :search] do
    post :search, on: :collection
    resources :build
  end

  resources :notifications, only: :index

  resources :users, constraints: { id: /[A-Za-z0-9\.]+/ }, only: [:show, :update, :destroy] do
    get :itineraries, on: :member
    resources :references, only: [:show, :new, :create, :update, :index]
  end

  # Admin Area
  namespace :admin do
    resources :users, only: [:index] do
      get :login_as, on: :member
      post :ban, :unban, on: :member
    end
  end

  mount Resque::Server, at: "/resque" if defined?(Resque::Server)

  # Sessions
  resources :sessions, only: [:create, :destroy]

  match 'auth/:provider', to: 'sessions#new', as: :auth_at_provider
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  delete 'signout', to: 'sessions#destroy', as: :logout

  # Root route aliases
  get :dashboard, to: 'users#dashboard'
  get :settings, to: 'users#settings'
  get :banned, to: 'users#banned'

  get :about, to: 'pages#about'
  get :how_it_works, to: 'pages#how_it_works'
  get :policy, to: 'pages#policy'
  get :terms, to: 'pages#terms'
  get :demo_terms, to: 'pages#demo_terms'
  get :fbjssdk_channel, to: 'pages#fbjssdk_channel'
end
