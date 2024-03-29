# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_admin, only: %i[impersonate]
  before_action :restrict_after_lock, only: %i[update]

  def show
    @user = User.find_by!(uid: params[:uid])

    casual_scores = Scores::SoloScores.get
    casual_presenter = Scores::UserScoresPresenter.new(casual_scores)
    casual_participants = casual_presenter.get
    @casual_stats = casual_participants.find { |h| h[:uid].to_s == @user.uid }

    insanity_scores = Scores::InsanityScores.get
    insanity_presenter = Scores::UserScoresPresenter.new(insanity_scores)
    insane_participants = insanity_presenter.get
    @insanity_stats = insane_participants.find { |h| h[:uid].to_s == @user.uid }

    squad_scores = Scores::SquadScores.get
    squad_presenter = Scores::SquadScoresPresenter.new(squad_scores)
    squads = squad_presenter.get
    @squad_stats = squads.find { |h| h[:id] == @user.squad_id }

    city_scores = Scores::CityScores.get
    city_presenter = Scores::CityScoresPresenter.new(city_scores)
    cities = city_presenter.get
    @campus_stats = cities.find { |h| h[:id] == @user.city_id }

    # Sort user achievements in the same order as in the YAML definition
    @achievements = @user.achievements
                         .pluck(:nature)
                         .sort_by { |nature| Achievement.keys.index(nature.to_sym) }

    @latest_day = Aoc.latest_day
    @daily_completions = Array.new(@latest_day) { [nil, nil] }

    Completion.where(user: @user).find_each do |completion|
      @daily_completions[@latest_day - completion.day][completion.challenge - 1] = completion
    end
  end

  def edit
    @squad = Squad.find_or_initialize_by(id: current_user.squad_id)
    @referees = current_user.referees
  end

  def update
    current_user.batch_id = -1 if params.dig(:user, :batch_number) # Set impossible value to trigger validation

    referrer_code = params.dig(:user, :referrer_code)
    current_user.referrer_id = User.find_by_referral_code(referrer_code)&.id || -1 if referrer_code

    if current_user.update(user_params)
      unlock_achievements
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

  def restrict_after_lock
    return unless Time.now.utc > Aoc.lewagon_lock_time && (user_params[:entered_hardcore] == "1") != current_user.entered_hardcore

    redirect_back(
      fallback_location: "/",
      alert: "You cannot join or leave the Ladder of Insanity since #{Aoc.lewagon_lock_time.to_fs(:long_ordinal)} (see FAQ)"
    )
  end

  def unlock_achievements
    Achievements::UnlockJob.perform_later(:city_join, current_user.id)
  end

  def user_params
    params
      .require(:user)
      .permit(:accepted_coc, :aoc_id, :city_id, :entered_hardcore, :event_awareness, :favourite_language, :username)
  end
end
