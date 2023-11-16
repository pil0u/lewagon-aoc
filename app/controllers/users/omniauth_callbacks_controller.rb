# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable

    def slack_openid
      auth = request.env["omniauth.auth"]
      token = auth&.credentials&.token

      return fail_auth("Couldn't acquire token") unless token
      return fail_auth("Can't link to unauthentified user") unless current_user

      client = Slack::Web::Client.new(token:)
      user_data = client.openid_connect_userInfo
      current_user.update!(
        slack_id: user_data["https://slack.com/user_id"],
        slack_username: user_data["name"],
        slack_access_token: token,
      )

      flash.notice = "Successfully linked Slack account!"
      redirect_to controller: "/users", action: "edit"
    rescue Slack::Web::Api::Errors::SlackError => e
      fail_auth("Info fetch failed - #{e.message}")
    rescue ActiveRecord::RecordInvalid => e
      fail_auth("Info recording failed - #{e.message}")
    end

    def kitt
      @user = User.from_kitt(request.env["omniauth.auth"])

      if @user.persisted?
        remember_me(@user)
        flash.notice = "Successfully signed in with Kitt!"
        sign_in_and_redirect @user, event: :authentication
      else
        fail_auth("Couldn't store information in database")
      end
    end

    def failure
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
