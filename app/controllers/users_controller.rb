# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_admin, only: %i[impersonate]

  def show
    # Profile details
    @user = User.find_by!(uid: params[:uid])
    @user_squad = @user.squad
    @latest_day = Aoc.latest_day

    user_completions = Scores::InsanityPoints.get.select { |completion| completion[:user_id] == @user.id }

    @daily_completions = Array.new(@latest_day) { [nil, nil] }
    user_completions.each do |completion|
      @daily_completions[@latest_day - completion[:day]][completion[:challenge] - 1] = completion
    end

    @silver_stars = @daily_completions.count { |day| day[0] && !day[1] }
    @gold_stars = @daily_completions.count { |day| day[1] }

    # Account settings
    return unless @user == current_user

    @account_squad = Squad.find_or_initialize_by(id: current_user.squad_id)
  end

  def update
    referrer_code = params.dig(:user, :referrer_code)
    current_user.referrer_id = User.find_by_referral_code(referrer_code)&.id || -1 if referrer_code

    if current_user.update(user_params)
      redirect_back fallback_location: "/", notice: "Your user information was updated"
    else
      redirect_back fallback_location: "/", alert: current_user.errors.full_messages[0].to_s
    end
  end

  def unlink_slack
    if current_user.update(slack_id: nil, slack_username: nil)
      redirect_back fallback_location: "/", notice: "Slack account successfully unlinked"
    else
      redirect_back fallback_location: "/", alert: current_user.errors.full_messages[0].to_s
    end
  end

  def me
    redirect_to profile_path(current_user.uid)
  end

  def impersonate
    attribute_name = params[:attribute]
    identifier_value = params[:identifier]

    user = User.find_by(attribute_name.to_sym => identifier_value)
    if user
      sign_in(user)
      redirect_to "/", alert: "You are now impersonating #{user.username} (id: #{user.id})"
    else
      redirect_back fallback_location: "/", alert: "User (#{attribute_name}: #{identifier_value}) not found"
    end
  end

  private

  def authenticate_admin
    return if current_user.admin?

    flash[:alert] = "You are not authorized to perform this action"
    redirect_to root_path
  end

  def user_params
    params
      .require(:user)
      .permit(:accepted_coc, :aoc_id, :city_id, :event_awareness, :favourite_language, :username)
      .compact_blank
  end
end
