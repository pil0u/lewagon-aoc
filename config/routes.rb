# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  unauthenticated do
    root "pages#welcome", as: :unauth_root
  end

  authenticated do
    constraints(ConfirmedConstraint.new) do
      root "pages#calendar", as: :calendar
      get "/scores", to: "pages#scores"
      get "/settings", to: "users#edit"
      patch "/settings", to: "users#update"
      get "/the-wall", to: "pages#the_wall"
    end

    root "pages#setup", as: :setup
    patch "/", to: "users#update"

    mount Blazer::Engine, at: "blazer", constraints: BlazerConstraint.new
  end

  get "/faq", to: "pages#faq"
  get "/code-of-conduct", to: "pages#code_of_conduct"
  get "/stats", to: "pages#stats"

  #                 #
  #  To be deleted  #
  # vvvvvvvvvvvvvvv #

  namespace "stats" do
    resources :users, only: [:show]
    # resources :days, only: [:show], param: :number
    resources :batches, only: [:show], param: :number
    resources :cities, only: [:show], param: :slug
  end

  get "/status", to: "pages#status"
end
