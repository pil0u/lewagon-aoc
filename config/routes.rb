# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  unauthenticated { root to: "pages#home", as: :unauth_root }
  authenticated { root to: "pages#dashboard" }

  get "/about", to: "pages#about"
  get "/scoreboard", to: "pages#scoreboard"
  get "/settings", to: "users#edit"
  patch "/settings", to: "users#update"

  get "/stats", to: "pages#stats"
  namespace "stats" do
    resources :users, only: [:show]
    resources :days, only: [:show], param: :number
    resources :batches, only: [:show], param: :number
    resources :cities, only: [:show], param: :slug
  end

  get "/status", to: "pages#status"
end
