# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :restrict_after_lock, only: %i[update]

  def show
    @user = User.find_by!(uid: params[:uid])

    solo_scores = Scores::SoloScores.get
    solo_presenter = Scores::SoloRanksPresenter.new(solo_scores)
    participants = solo_presenter.ranks
    @solo_stats = participants.find { |h| h[:uid].to_s == @user.uid }

    squad_scores = Scores::SquadScores.get
    squad_presenter = Scores::SquadRanksPresenter.new(squad_scores)
    squads = squad_presenter.ranks
    @squad_stats = squads.find { |h| h[:id] == @user.squad_id }

    city_scores = Scores::CityScores.get
    city_presenter = Scores::CityRanksPresenter.new(city_scores)
    cities = city_presenter.ranks
    @city_stats = cities.find { |h| h[:id] == @user.city_id }
  end

  def edit
    @squad = Squad.find_or_initialize_by(id: current_user.squad_id)
  end

  def update
    set_updated_params

    if current_user.update(@params)
      redirect_back fallback_location: "/", notice: "Your user information was updated"
    else
      redirect_back fallback_location: "/", alert: current_user.errors.full_messages[0].to_s
    end
  end

  private

  def restrict_after_lock
    return unless Time.now.utc > Aoc.lock_time && (form_params[:entered_hardcore] == "1") != current_user.entered_hardcore

    redirect_back(
      fallback_location: "/",
      alert: "You cannot join or leave the Ladder of Insanity since #{Aoc.lock_time.to_fs(:long_ordinal)} (see FAQ)"
    )
  end

  def set_updated_params
    @params = {
      accepted_coc: form_params[:accepted_coc],
      aoc_id: form_params[:aoc_id],
      batch_id: Batch.find_or_create_by(number: form_params[:batch_number].to_i).id,
      # find_or_create_by always returns an instance of Batch, even if it failed to create. If creation did fail (from
      # validation), then the id of that instance is nil, which disappears with .compact below
      city: City.find_by(id: form_params[:city_id]),
      entered_hardcore: form_params[:entered_hardcore],
      username: form_params[:username]
    }.compact
  end

  def form_params
    params.require(:user).permit(:accepted_coc, :aoc_id, :batch_number, :city_id, :entered_hardcore, :username)
  end
end
