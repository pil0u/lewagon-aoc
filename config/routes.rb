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
  get "/stats",           to: "pages#stats"
  get "/scores/insanity", to: "scores#insanity"

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
    get     "/",                                to: "pages#calendar", as: :calendar
    get     "/countdown",                       to: "pages#countdown"
    get     "/patrons",                         to: "pages#patrons"
    get     "/campus/:slug",                    to: "campuses#show",   as: :campus
    get     "/city/:slug",                      to: "campuses#show",   as: :city # Retrocompat in case of old links
    get     "/day/:day",                        to: "days#show",       as: :day,            day: /[1-9]|1\d|2[0-5]/
    get     "/day/:day/:challenge",             to: "snippets#show",   as: :snippet,        day: /[1-9]|1\d|2[0-5]/, challenge: /[1-2]/, constraints: AllowedToSeeSolutionsConstraint.new
    post    "/day/:day/:challenge",             to: "snippets#create",                      day: /[1-9]|1\d|2[0-5]/, challenge: /[1-2]/, constraints: AllowedToSeeSolutionsConstraint.new
    get     "/snippets/:id/edit",               to: "snippets#edit",   as: :edit_snippet,   day: /[1-9]|1\d|2[0-5]/, challenge: /[1-2]/, constraints: AllowedToSeeSolutionsConstraint.new
    patch   "/snippets/:id",                    to: "snippets#update", as: :update_snippet, day: /[1-9]|1\d|2[0-5]/, challenge: /[1-2]/, constraints: AllowedToSeeSolutionsConstraint.new
    get     "/the-wall",                        to: "messages#index",  as: :messages
    post    "/the-wall",                        to: "messages#create"
    get     "/squad/:id",                       to: "squads#show",      as: :squad
    post    "/squad",                           to: "squads#create",    as: :create_squad
    patch   "/squad/:id",                       to: "squads#update",    as: :update_squad
    post    "/squad/join",                      to: "squads#join",      as: :join_squad
    delete  "/squad/leave",                     to: "squads#leave",     as: :leave_squad
    get     "/profile/:uid",                    to: "users#show",       as: :profile
    patch   "/settings",                        to: "users#update"
    post    "/snippets/:snippet_id/reactions",  to: "reactions#create",  as: :reactions
    patch   "/reactions/:id",                   to: "reactions#update",  as: :update_reaction
    delete  "/reactions/:id",                   to: "reactions#destroy", as: :delete_reaction
  end

  # Admin routes
  authenticated :user, ->(user) { user.admin? } do
    get   "/admin",           to: "pages#admin"
    post  "/impersonate",     to: "users#impersonate", as: :impersonate

    get   "/scores/solo",     to: "scores#solo"
    get   "/scores/squads",   to: "scores#squads"
    get   "/scores/campuses", to: "scores#campuses"
    get   "/participation",   to: "pages#participation"

    mount Blazer::Engine,     at: "blazer"
    mount GoodJob::Engine,    at: "good_job"
  end
end
