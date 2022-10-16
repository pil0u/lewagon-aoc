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

      def failure # rubocop:disable Lint/NestedMethodDefinition
        reason = request.env["omniauth.auth"]&.error_description

        redirect_back(fallback_location: "/",
                      alert: "Failed to sign in with Kitt (Reason: #{reason || 'Unknown'}).")
      end
    end
  end
end
