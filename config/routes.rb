# frozen_string_literal: true

Rails.application.routes.draw do
  # Devise sign in and sign out with OmniAuth
  devise_for :users, skip: :omniauth_callbacks, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # Needed because Devise is all-or-nothing wrt providers
  def omniauth_callbacks(provider)
    OmniAuth.config.path_prefix = "/users/auth"

    devise_scope :user do
      with_devise_exclusive_scope "users", "user", {} do
        match "auth/#{provider}",
              to: "users/omniauth_callbacks#passthru",
              as: "#{provider}_omniauth_authorize",
              via: OmniAuth.config.allowed_request_methods

        match "auth/#{provider}/callback",
              to: "users/omniauth_callbacks##{provider}",
              as: "#{provider}_omniauth_callback",
              via: %i[get post]
      end
    end
  end

  omniauth_callbacks(:kitt)

  devise_scope :user do
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  # Public routes
  get "/code-of-conduct", to: "pages#code_of_conduct"
  get "/faq",             to: "pages#faq"
  get "/participation",   to: "pages#participation"
  get "/stats",           to: "pages#stats"

  # Routes for unauthenticated users
  unauthenticated do
    get "/", to: "pages#welcome"
    get "/admin", to: "pages#admin"
  end

  authenticated :user do
    omniauth_callbacks(:slack_openid)

    delete "slack_omniauth", to: "users#unlink_slack", as: :user_slack_omniauth_remove
  end

  # Routes for authenticated + unconfirmed users
  authenticated :user, ->(user) { !user.confirmed? } do
    get   "/",          to: "pages#setup", as: :setup
    patch "/",          to: "users#update"
    patch "/settings",  to: "users#update"
  end

  # Routes for authenticated + confirmed users
  authenticated :user, ->(user) { user.confirmed? } do
    get     "/",                    to: "pages#calendar", as: :calendar
    get     "/countdown",           to: "pages#countdown"
    get     "/campuses/:slug",      to: "campuses#show",  as: :campus
    get     "/city/:slug",          to: "campuses#show",  as: :city # Retrocompat in case of old links
    get     "/day/:day",            to: "days#show",      as: :day,     day: /[1-9]|1\d|2[0-5]/
    get     "/day/:day/:challenge", to: "snippets#show",  as: :snippet, day: /[1-9]|1\d|2[0-5]/, challenge: /[1-2]/, constraints: SolvedPuzzleConstraint.new
    post    "/day/:day/:challenge", to: "snippets#create",              day: /[1-9]|1\d|2[0-5]/, challenge: /[1-2]/, constraints: SolvedPuzzleConstraint.new
    get     "/the-wall",            to: "messages#index", as: :messages
    post    "/the-wall",            to: "messages#create"
    get     "/scores/campuses",     to: "scores#campuses"
    get     "/scores/cities",       to: "scores#campuses" # Retrocompat in case of old links
    get     "/scores/insanity",     to: "scores#insanity"
    get     "/scores/solo",         to: "scores#solo"
    get     "/scores/squads",       to: "scores#squads"
    get     "/squad/:id",           to: "squads#show",      as: :squad
    post    "/squad",               to: "squads#create",    as: :create_squad
    patch   "/squad/:id",           to: "squads#update",    as: :update_squad
    post    "/squad/join",          to: "squads#join",      as: :join_squad
    delete  "/squad/leave",         to: "squads#leave",     as: :leave_squad
    get     "/profile/:uid",        to: "users#show",       as: :profile
    get     "/settings",            to: "users#edit"
    patch   "/settings",            to: "users#update"
  end

  # Admin routes
  authenticated :user, ->(user) { user.admin? } do
    get "/admin",         to: "pages#admin"
    post "/impersonate",  to: "users#impersonate", as: :impersonate

    mount Blazer::Engine,   at: "blazer"
    mount GoodJob::Engine,  at: "good_job"
  end
end
