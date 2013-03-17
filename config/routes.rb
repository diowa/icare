Icare::Application.routes.draw do

  root to: 'pages#home'

  resources :users, constraints: { id: /[A-Za-z0-9\.]+/ }, only: [:show, :create, :edit, :update, :destroy, :index] do
    get :itineraries, on: :member
    post :ban, :unban, on: :member
    resources :references, only: [:show, :new, :create, :update, :index]
  end

  match 'dashboard', to: 'users#dashboard', as: :dashboard
  match 'settings', to: 'users#settings', as: :settings
  match 'banned', to: 'users#banned', as: :banned

  resources :itineraries, only: [:show, :new, :create, :edit, :update, :destroy, :index, :search] do
    post :search, on: :collection
    resources :build
  end

  resources :conversations, only: [:show, :new, :create, :update, :index] do
    get :unread, on: :collection
    resources :messages, only: [:create]
  end

  resources :notifications, only: :index

  resources :pages, only: [] do
    get :home, :about, :how_it_works, :policy, :terms, :fbjssdk_channel, on: :member
  end
  match 'about', to: 'pages#about', as: :about
  match 'how_it_works', to: 'pages#how_it_works', as: :how_it_works
  match 'policy', to: 'pages#policy', as: :policy
  match 'terms', to: 'pages#terms', as: :terms
  match 'demo_terms', to: 'pages#demo_terms', as: :demo_terms

  match 'fbjssdk_channel', to: 'pages#fbjssdk_channel', as: :fbjssdk_channel

  resources :feedbacks, only: [:show, :new, :create, :edit, :update, :destroy, :index]

  resources :sessions, only: [:create, :destroy]

  match 'auth/:provider', to: 'sessions#new', as: :auth_at_provider
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: :logout

  mount Resque::Server, at: "/resque" if defined?(Resque::Server)
end
