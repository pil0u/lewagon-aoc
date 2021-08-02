class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def kitt
    # pp request.env["omniauth.auth"]
    @user = User.from_kitt(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      flash.notice = "Successfully signed in with Kitt!"
    else
      redirect_to root_path
      flash.alert = "For an unknown reason, we couldn't store your information in our database. Please #{view_context.link_to("contact Pilou", "https://lewagon-alumni.slack.com/team/URZ0F4TEF", class: "text-aoc-green-flash text-shadow-green", target: :blank)}."
    end

    def failure
      redirect_to root_path
      flash.alert = "Failed to sign in with Kitt (Reason: #{request.env["omniauth.auth"]&.error_description || "Unknown"}). If it persists, please #{view_context.link_to("contact Pilou", "https://lewagon-alumni.slack.com/team/URZ0F4TEF", class: "text-aoc-green-flash text-shadow-green", target: :blank)}."
    end
  end
end

