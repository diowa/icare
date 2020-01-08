# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: 'pages#home'

  resources :conversations, only: %i[show new create update index] do
    get :unread, on: :collection
  end

  resources :feedbacks, only: %i[show new create edit update destroy index]

  resources :itineraries, only: %i[show new create edit update destroy index search] do
    post :search, on: :collection
    resources :build
  end

  resources :users, only: %i[show update destroy] do
    get :itineraries, on: :member
  end

  # Admin Area
  namespace :admin do
    resources :users, only: [:index] do
      get :login_as, on: :member
      post :ban, :unban, on: :member
    end
  end

  # Root route aliases
  get :dashboard, to: 'users#dashboard'
  get :settings, to: 'users#settings'
  get :banned, to: 'users#banned'

  get :about, to: 'pages#about'
  get :how_it_works, to: 'pages#how_it_works'
  get :privacy, to: 'pages#privacy'
  get :terms, to: 'pages#terms'
  get :demo_terms, to: 'pages#demo_terms'
  post :report_uri, to: 'pages#report_uri'
end
