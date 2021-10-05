Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  unauthenticated { root to: "pages#home", as: :unauth_root }
  authenticated { root to: "pages#dashboard" }

  get "/scoreboard", to: "pages#scoreboard"
  get "/settings", to: "pages#settings"
end
