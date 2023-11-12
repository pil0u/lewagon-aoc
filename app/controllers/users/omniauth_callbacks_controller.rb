# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    def kitt
      @user = User.from_kitt(request.env["omniauth.auth"])

      if @user.persisted?
        remember_me(@user)
        sign_in_and_redirect @user, event: :authentication
        flash.notice = "Successfully signed in with Kitt!"
      else
        redirect_back(fallback_location: "/",
                      alert: "For an unknown reason, we couldn't store your information in our database.")
      end
    end

    def failure # rubocop:disable Lint/NestedMethodDefinition
      fail_auth(failure_message)
    end

    private

    def fail_auth(reason)
      provider = request.env["omniauth.strategy"]&.name || "unknown"

      redirect_back(fallback_location: "/",
        alert: "Failed to sign in with #{provider.titleize} (Reason: #{reason}).")
    end
  end
end
