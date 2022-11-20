# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  get "/code-of-conduct", to: "pages#code_of_conduct"
  get "/faq",             to: "pages#faq"
  get "/participation",   to: "pages#participation"
  get "/stats",           to: "pages#stats"

  unauthenticated do
    get "/", to: "pages#welcome"
  end

  authenticated :user, ->(user) { !user.confirmed? } do
    get   "/",  to: "pages#setup", as: :setup
    patch "/",  to: "users#update"
  end

  authenticated :user, ->(user) { user.confirmed? } do
    get     "/",                to: "pages#calendar", as: :calendar
    get     "/city/:slug",      to: "cities#show",    as: :city
    get     "/day/:number",     to: "days#show",      as: :day, number: /[1-9]|1\d|2[0-5]/
    get     "/the-wall",        to: "messages#index", as: :messages
    get     "/scores/cities",   to: "scores#cities"
    get     "/scores/insanity", to: "scores#insanity"
    get     "/scores/solo",     to: "scores#solo"
    get     "/scores/squads",   to: "scores#squads"
    get     "/squad/:id",       to: "squads#show",    as: :squad
    post    "/squad",           to: "squads#create",  as: :create_squad
    patch   "/squad/:id",       to: "squads#update",  as: :update_squad
    post    "/squad/join",      to: "squads#join",    as: :join_squad
    delete  "/squad/leave",     to: "squads#leave",   as: :leave_squad
    get     "/profile/:uid",    to: "users#show",     as: :profile
    get     "/settings",        to: "users#edit"
    patch   "/settings",        to: "users#update"
  end

  authenticated :user, ->(user) { user.admin? } do
    mount Blazer::Engine,   at: "blazer"
    mount GoodJob::Engine,  at: "good_job"
  end
end
