class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def kitt
    # puts request.env["omniauth.auth"]
    @user = User.from_kitt(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      flash.notice = "Successfully logged in with Kitt!"
    else
      redirect_to root_path
      flash.alert = "Failed to sign in with Kitt."
    end
  end
end
