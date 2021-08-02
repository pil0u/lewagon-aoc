class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def kitt
    # pp request.env["omniauth.auth"]
    @user = User.from_kitt(request.env["omniauth.auth"])
    @contact_me = view_context.link_to(
      "contact Pilou",
      "https://lewagon-alumni.slack.com/team/URZ0F4TEF",
      target: :blank,
      class: "text-white text-shadow-white"
    ).html_safe

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      flash.notice = "Successfully signed in with Kitt!"
    else
      redirect_to root_path
      flash.alert = "For an unknown reason, we couldn't store your information in our database. Please #{@contact_me}."
    end

    def failure
      reason = request.env["omniauth.auth"]&.error_description
      redirect_to root_path
      flash.alert = "Failed to sign in with Kitt (Reason: #{reason || "Unknown"}). If it persists, please #{@contact_me}."
    end
  end
end
