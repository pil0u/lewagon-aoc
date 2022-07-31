# frozen_string_literal: true

Rails.application.routes.draw do
  mount Blazer::Engine, at: "blazer"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  unauthenticated do
    root "pages#welcome", as: :unauth_root
  end

  authenticated do
    root "pages#calendar", constraints: SyncedConstraint.new, as: :calendar
    root "pages#setup", as: :setup
  end

  get "/faq", to: "pages#faq"
  get "/scores", to: "pages#scores"
  get "/settings", to: "users#edit"
  patch "/settings", to: "users#update"

  get "/stats", to: "pages#stats"
  namespace "stats" do
    resources :users, only: [:show]
    # resources :days, only: [:show], param: :number
    resources :batches, only: [:show], param: :number
    resources :cities, only: [:show], param: :slug
  end

  get "/status", to: "pages#status"
end
