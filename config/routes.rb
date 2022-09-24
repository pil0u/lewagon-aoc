# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  unauthenticated do
    get "/", to: "pages#welcome"
  end

  authenticated do
    constraints(ConfirmedConstraint.new) do
      get     "/",            to: "pages#calendar", as: :calendar
      # get     "/city/:slug",  to: "cities#show",    as: :city
      get     "/day/:number", to: "days#show",      as: :day, number: /[1-9]|1\d|2[0-5]/
      get     "/the-wall",    to: "messages#index", as: :messages
      get     "/scores",      to: "pages#scores"
      post    "/squad",       to: "squads#create",  as: :create_squad
      post    "/squad/join",  to: "squads#join",    as: :join_squad
      delete  "/squad/leave", to: "squads#leave",   as: :leave_squad
      patch   "/squad/:id",   to: "squads#update",  as: :update_squad
      # get     "/squad/:id",   to: "squads#show",    as: :squad
      get     "/settings",    to: "users#edit"
      patch   "/settings",    to: "users#update"
      # get     "/profile/:id", to: "users#show",     as: :profile
    end

    get   "/",  to: "pages#setup", as: :setup
    patch "/",  to: "users#update"
  end

  get "/code-of-conduct", to: "pages#code_of_conduct"
  get "/faq",             to: "pages#faq"
  get "/stats",           to: "pages#stats"

  mount Blazer::Engine, at: "blazer", constraints: BlazerConstraint.new
end
